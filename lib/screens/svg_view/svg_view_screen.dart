import 'package:flutter/material.dart';
import 'package:number_painter/core/db_provider.dart';
import 'package:number_painter/core/models/coloring_shape.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:number_painter/core/models/svg_models/svg_line_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/screens/svg_view/widgets/checkers_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/circle_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/color_picker.dart';
import 'package:number_painter/screens/svg_view/widgets/fade_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/line_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/number_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/shape_painter.dart';
import 'package:xml/xml.dart';

//TODO: может сделать InheritedWidget для переброса инфы?

class SvgViewScreen extends StatefulWidget {
  final String id;
  const SvgViewScreen({required this.id, Key? key}) : super(key: key);

  @override
  _SvgViewScreenState createState() => _SvgViewScreenState();
}

class _SvgViewScreenState extends State<SvgViewScreen> with TickerProviderStateMixin {
  final _offsetNotifier = ValueNotifier(Offset.zero); //TODO: сделать через provider
  final _scaleNotifier = ValueNotifier(1.0); //TODO: сделать через provider

  final List<XmlElement> _stringSvgPathShapes = [];
  final List<SvgShapeModel> _svgShapes = [];
  final List<SvgLineModel> _svgLines = [];
  final Map<Color, List<SvgShapeModel>> _sortedShapes = {};
  final List<ColoringShape> _selectedColoringShapes = [];

  late final _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  late final _percentController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

  late final PainterProgressModel _painterProgress;

  final _dbProvider = DBProvider();

  Size svgSize = Size.zero;
  Size fittedSvgSize = Size.zero;

  List<SvgShapeModel> _selectedSvgShapes = [];
  SvgShapeModel _selectedShape = SvgShapeModel.epmty();

  Color? _getSelectedColor;
  bool _isInteract = false;
  bool _isInit = false;

  final _tranformController = TransformationController();

  @override
  void dispose() {
    _fadeController.dispose();
    _percentController.dispose();
    _offsetNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/${widget.id}.svg').then((value) {
      final svgAttributes = XmlDocument.parse(value).findElements('svg').first.attributes;
      debugPrint(svgAttributes.toString());
      svgSize = Size(
        double.parse(
          svgAttributes.firstWhere((attribute) => attribute.name.toString() == 'width').value,
        ),
        double.parse(
          svgAttributes.firstWhere((attribute) => attribute.name.toString() == 'height').value,
        ),
      );
      _stringSvgPathShapes.addAll((XmlDocument.parse(value).findAllElements('path')).toList());
      final canvasSize = Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * 0.85,
      );
      debugPrint(canvasSize.toString());
      final fs = applyBoxFit(BoxFit.contain, svgSize, canvasSize);
      fittedSvgSize = fs.destination;
      final r = Alignment.center.inscribe(fs.destination, Offset.zero & canvasSize);
      //final r = Alignment.center.inscribe(canvasSize, Offset.zero & canvasSize);
      final matrix = Matrix4.translationValues(r.left, r.top, 0)..scale(fs.destination.width / fs.source.width);
      for (final itemPath in _stringSvgPathShapes) {
        if (itemPath.toString().contains('fill')) {
          final shape = SvgShapeModel.fromElement(itemPath)..transform(matrix);
          _svgShapes.add(shape);
        }
        if (itemPath.toString().contains('stroke')) {
          _svgLines.add(SvgLineModel.fromElement(itemPath)..transform(matrix));
        }
      }

      _painterProgress = PainterProgressModel.fromScratch(id: widget.id, shapes: _svgShapes.join(' '), isCompleted: false);
      _dbProvider.getPainter(widget.id).then((painter) async {
        if (painter != null) {
          debugPrint(painter.id);
          final dbShapesStringList = painter.shapes.split(' ');
          final shapesList = dbShapesStringList.map((e) => e.split(',')[1]).toList();
          for (var i = 0; i < _svgShapes.length; i++) {
            _svgShapes[i].isPainted = shapesList[i] == 'true';
          }
        } else {
          await _dbProvider.addNewPainter(_painterProgress);
        }
        _sortedShapes.addAll(_setSortedShapes(_svgShapes));
        _isInit = true;
        setState(() {});
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build');
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isInit
          ? Column(
              children: <Widget>[
                const Spacer(),
                InteractiveViewer(
                  transformationController: _tranformController,
                  onInteractionUpdate: (details) {
                    //debugPrint(details.scale.toString());
                    _scaleNotifier.value = _tranformController.value.getMaxScaleOnAxis();
                  },
                  minScale: 0.5,
                  maxScale: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: fittedSvgSize.width,
                        height: fittedSvgSize.height,
                        child: const CheckersPaint(),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: ManyCirclesPaint(notifier: _offsetNotifier, selectedColoredShapes: _selectedColoringShapes),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: FadePaint(fadeController: _fadeController, selectedSvgShapes: _selectedSvgShapes),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: //SvgPicture.string(stringSvg),
                            Listener(
                          onPointerUp: (e) {
                            if (!_isInteract) {
                              debugPrint('up');
                              for (final shape in _selectedSvgShapes) {
                                if (shape.transformedPath!.contains(e.localPosition)) {
                                  if (_selectedShape != shape && !shape.isPainted) {
                                    setState(() {
                                      _selectedShape = shape;
                                      _selectedColoringShapes.add(ColoringShape(cicrclePosition: e.localPosition, shape: shape));
                                      _offsetNotifier.value = e.localPosition;

                                      _isInteract = true;
                                    });
                                    _percentController.forward(from: 0.0);
                                    //_selectedShape.isPainted = true;
                                    //_painterProgress.shapes = _svgShapes.join(' ');
                                    //_dbProvider.updatePainter(_painterProgress);
                                    _isInteract = false;
                                  }
                                }
                              }
                            }
                          },
                          child: RepaintBoundary(
                            child: CustomPaint(
                              isComplex: true,
                              painter: ShapePainter(
                                notifier: _offsetNotifier,
                                shapes: _svgShapes,
                                selectedShapes: _selectedSvgShapes,
                                lines: _svgLines,
                                sortedShapes: _sortedShapes,
                                selectedColor: _getSelectedColor,
                                isInit: _isInit,
                                center: Offset(
                                  MediaQuery.of(context).size.width / 2,
                                  MediaQuery.of(context).size.height * 0.85 / 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      /* SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            isComplex: true,
                            painter: ShapeStrokePainter(shapes: _svgShapes),
                            ),),
                      ), */
                      IgnorePointer(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: LinePaint(svgLines: _svgLines),
                        ),
                      ),
                      IgnorePointer(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ValueListenableBuilder(
                            valueListenable: _scaleNotifier,
                            builder: (context, scale, child) {
                              return RepaintBoundary(
                                child: CustomPaint(
                                  painter: NumberPainter(shapes: _svgShapes, scale: scale as double),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Divider(
                  height: 1,
                  color: Colors.black,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.14,
                  width: MediaQuery.of(context).size.width,
                  child: ColorPicker(
                    percentController: _percentController,
                    sortedShapes: _sortedShapes,
                    setSelectedColor: _callBackIndexColorOfColorPicker,
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _callBackIndexColorOfColorPicker(Color selectedColor) {
    setState(() {
      if (_getSelectedColor != selectedColor) {
        _selectedColoringShapes.clear();
        _fadeController.reset();
        _getSelectedColor = selectedColor;
        _selectedSvgShapes = _sortedShapes[selectedColor]!;
        for (final shape in _svgShapes) {
          if (shape.fill == _getSelectedColor) {
            shape.isPicked = true;
          } else {
            shape.isPicked = false;
          }
        }
        _isInteract = _getSelectedColor == null;
        _fadeController.forward();
      }
      debugPrint('_callBackIndexColorOfColorPicker: $_getSelectedColor');
    });
  }

  Map<Color, List<SvgShapeModel>> _setSortedShapes(List<SvgShapeModel> shapes) {
    debugPrint(DateTime.now().toString());
    final sortedShapes = <Color, List<SvgShapeModel>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(shape.fill)) {
        sortedShapes[shape.fill]!.add(shape);
        shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.number = PainterNumber(dx: 0, dy: 0, number: sortedShapes.keys.toList().indexOf(shape.fill), size: 0);
        //await _setNumberProperties(shape, sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      } else {
        sortedShapes[shape.fill] = [shape];
        shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.number = PainterNumber(dx: 0, dy: 0, number: sortedShapes.keys.toList().indexOf(shape.fill), size: 0);
        //await _setNumberProperties(shape, sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      }
    }
    debugPrint(DateTime.now().toString());
    return sortedShapes;
  }
}
