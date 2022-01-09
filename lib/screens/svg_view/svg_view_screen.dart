import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_line.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';
import 'package:number_painter/core/painters/checkers_painter.dart';
import 'package:number_painter/core/painters/circle_painer.dart';
import 'package:number_painter/core/painters/fade_painter.dart';
import 'package:number_painter/core/painters/line_painter.dart';
import 'package:number_painter/core/painters/shape_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/color_picker.dart';
import 'package:xml/xml.dart';

//TODO: может сделать InheritedWidget для переброса инфы?

class SvgViewScreen extends StatefulWidget {
  const SvgViewScreen({Key? key}) : super(key: key);

  @override
  _SvgViewScreenState createState() => _SvgViewScreenState();
}

class _SvgViewScreenState extends State<SvgViewScreen> with TickerProviderStateMixin {
  final _notifier = ValueNotifier(Offset.zero);

  final List<XmlElement> _stringSvgPathShapes = [];
  final Iterable<XmlElement> _stringSvgPathLines = [];
  final List<ModelSvgShape> _svgShapes = [];
  final List<ModelSvgLine> _svgLines = [];
  final Map<Color, List<ModelSvgShape>> _sortedShapes = {};
  late final AnimationController _fadeController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  )..addListener(() => setState(() {}));

  late final AnimationController _fillController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..addListener(() => setState(() {}));

  late final AnimationController _percentController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  Size svgSize = Size.zero;
  Size fittedSvgSize = Size.zero;

  List<ModelSvgShape> _selectedSvgShapes = [];
  //Path _selectedPath = Path();
  ModelSvgShape _selectedShape = ModelSvgShape.epmty();

  Color? _getSelectedColor;
  bool _isInteract = false;
  bool _isInit = false;

  final _transformationController = TransformationController();

  @override
  void dispose() {
    _fadeController.dispose();
    _percentController.dispose();
    _fillController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/landscape1.svg').then((value) {
      setState(() {
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
            _svgShapes.add(ModelSvgShape.fromElement(itemPath)..transform(matrix));
          }
          if (itemPath.toString().contains('stroke')) {
            _svgLines.add(ModelSvgLine.fromElement(itemPath)..transform(matrix));
          }
        }
        _sortedShapes.addAll(_setSortedShapes(_svgShapes));
        _isInit = true;
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
                  maxScale: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: fittedSvgSize.width,
                        height: fittedSvgSize.height,
                        child: const RepaintBoundary(
                          child: CustomPaint(
                            isComplex: true,
                            painter: ShapePainter(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: FadePainter(animation: _fadeController, selectedShapes: _selectedSvgShapes),
                          ),
                        ),
                      ),
                      if (_selectedShape.transformedPath != null)
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: CirclePainter(notifier: _notifier, radius: _fillController.value * 100, selectedShape: _selectedShape),
                            ),
                          ),
                        ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: //SvgPicture.string(stringSvg),
                            Listener(
                          /* onPointerUp: (e) {
                            if (!_isInteract) {
                              debugPrint('up');
                              _fillController.reset();
                              for (final shape in _selectedSvgShapes) {
                                if (shape.transformedPath!.contains(e.localPosition)) {
                                  if (_selectedShape != shape && !shape.isPainted) {
                                    _percentController.reset();
                                    setState(() {
                                      _selectedShape = shape;
                                      _notifier.value = e.localPosition;
                                      _isInteract = true;
                                    });
                                    _fillController.forward().then((_) {
                                      _selectedShape.isPainted = true;
                                      _isInteract = false;
                                      _percentController.forward();
                                    });
                                  }
                                }
                              }
                            }
                          }, */
                          child: RepaintBoundary(
                            child: CustomPaint(
                              isComplex: true,
                              painter: SvgPainter(
                                notifier: _notifier,
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
                          child: RepaintBoundary(
                            child: CustomPaint(
                              isComplex: true,
                              painter: LinePainter(lines: _svgLines),
                            ),
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

  Map<Color, List<ModelSvgShape>> _setSortedShapes(List<ModelSvgShape> shapes) {
    debugPrint(DateTime.now().toString());
    final sortedShapes = <Color, List<ModelSvgShape>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(shape.fill)) {
        sortedShapes[shape.fill]!.add(shape);
        //shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.number = PainterNumber(dx: 0, dy: 0, number: sortedShapes.keys.toList().indexOf(shape.fill), size: 0);
        //await _setNumberProperties(shape, sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      } else {
        sortedShapes[shape.fill] = [shape];
        //shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.number = PainterNumber(dx: 0, dy: 0, number: sortedShapes.keys.toList().indexOf(shape.fill), size: 0);
        //await _setNumberProperties(shape, sortedShapes.keys.toList().indexOf(shape.fill));
        //shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      }
    }
    debugPrint(DateTime.now().toString());
    return sortedShapes;
  }
}
