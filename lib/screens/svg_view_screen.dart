import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/checkers_painter.dart';
import 'package:number_painter/circle_painer.dart';
import 'package:number_painter/custom_clipper.dart';
import 'package:number_painter/fade_painter.dart';
import 'package:number_painter/widgets/color_picker.dart';
import 'package:number_painter/main.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';
import 'package:number_painter/svg_painter.dart';
import 'package:xml/xml.dart';

//TODO: может сделать InheritedWidget для переброса инфы?

class SvgViewScreen extends StatefulWidget {
  const SvgViewScreen({Key? key}) : super(key: key);

  @override
  _SvgViewScreenState createState() => _SvgViewScreenState();
}

class _SvgViewScreenState extends State<SvgViewScreen> with TickerProviderStateMixin {
  final notifier = ValueNotifier(Offset.zero);

  final List<XmlElement> stringSvgPathShapes = [];
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

  double oldPercent = 0.5;

  List<ModelSvgShape> _selectedSvgShapes = [];
  //Path _selectedPath = Path();
  ModelSvgShape _selectedShape = ModelSvgShape.epmty();

  Color? _getSelectedColor;
  bool _isInteract = false;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    DefaultAssetBundle.of(context).loadString('assets/landscape.svg').then((value) {
      setState(() {
        stringSvgPathShapes.addAll((XmlDocument.parse(value).findAllElements('path')).toList());
        final canvasSize = Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.85,
        );
        debugPrint(canvasSize.toString());
        final fs = applyBoxFit(BoxFit.contain, const Size(580, 260), canvasSize);
        final r = Alignment.center.inscribe(fs.destination, Offset.zero & canvasSize);
        //final r = Alignment.center.inscribe(canvasSize, Offset.zero & canvasSize);
        final matrix = Matrix4.translationValues(r.left, r.top, 0)..scale(fs.destination.width / fs.source.width);
        for (final itemPath in stringSvgPathShapes) {
          if (itemPath.toString().contains('fill')) {
            _svgShapes.add(ModelSvgShape.fromElement(itemPath)..transform(matrix));
          }
          if (itemPath.toString().contains('stroke')) {
            _svgLines.add(ModelSvgLine.fromElement(itemPath)..transform(matrix));
          }
        }
      });
      _sortedShapes.addAll(_setSortedShapes(_svgShapes));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          const Spacer(),
          InteractiveViewer(
            //onInteractionStart: !_isInteract ? (_) => setState(() => _isInteract = true) : null,
            //onInteractionEnd: (_) => setState(() => _isInteract = _getSelectedColor == null ),
            maxScale: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
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
                  child: CustomPaint(
                    painter: FadePainter(animation: _fadeController, selectedShapes: _selectedSvgShapes),
                  ),
                ),
                if (_selectedShape.transformedPath != null)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: CustomPaint(
                      painter: CirclePainter(notifier: notifier, radius: _fillController.value * 100, selectedShape: _selectedShape),
                    ),
                  ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: //SvgPicture.string(stringSvg),
                      Listener(
                    onPointerUp: (e) {
                      if (!_isInteract) {
                        debugPrint('up');
                        _fillController.reset();
                        if (_selectedSvgShapes != null) {
                          for (final shape in _selectedSvgShapes) {
                            if (shape.transformedPath!.contains(e.localPosition)) {
                              if (_selectedShape != shape && !shape.isPainted) {
                                _percentController.reset();
                                setState(() {
                                  _selectedShape = shape;
                                  notifier.value = e.localPosition;
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
                      }
                    },
                    child: RepaintBoundary(
                      child: CustomPaint(
                        isComplex: true,
                        painter: SvgPainter(
                          notifier: notifier,
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
      ),
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

  Future<void> _setNumberProperties(ModelSvgShape shape, int number) async {
    final path = shape.transformedPath;
    final metrics = path!.computeMetrics();
    final bounds = path.getBounds();
    var txtSize = metrics.elementAt(0).length * .1;
    /* for (final metric in metrics) {
      txtSize += metric.length.toDouble();
    }
    txtSize *= 0.05; */

    // print(bounds.longestSide);

    var textRect = Rect.fromCenter(center: bounds.center - Offset(txtSize / 5, -txtSize / 8), width: txtSize / 2, height: txtSize);
    var isInclude = false;

    var txtOffset = bounds.center;
    var x = bounds.topLeft.dx;
    var y = bounds.bottomRight.dy;
    do {
      for (var dx = x; dx < bounds.topRight.dx; dx += 1.0) {
        for (var dy = y; dy > bounds.topRight.dy; dy -= 1.0) {
          if (path.contains(Offset(dx.toDouble(), dy.toDouble()))) {
            textRect = Rect.fromCenter(
                center: Offset(dx, dy) - Offset(txtSize / 5, -txtSize / 8), width: (txtSize / 2) + (txtSize / 2), height: txtSize + txtSize / 2);
            for (var i = textRect.topLeft.dx; i < textRect.topRight.dx; i += 1.0) {
              for (var j = textRect.bottomRight.dy; j > textRect.topRight.dy; j -= 1.0) {
                if (path.contains(Offset(i, j))) {
                  isInclude = true;
                } else {
                  isInclude = false;
                  break;
                }
              }
              if (!isInclude) {
                break;
              }
            }
            if (!isInclude) {
              continue;
            } else {
              x = dx;
              y = dy;
              break;
            }
          } else {
            isInclude = false;
            continue;
          }
        }
        if (!isInclude) {
          continue;
        } else {
          /* debugPrint('include size: ${txtSize.toString()}');
          debugPrint('center: ${bounds.center}');
          debugPrint('included: $x,$y');
          txtOffset = Offset(x, y); */
          break;
        }
      }
      if (!isInclude) {
        //debugPrint('not include size: ${txtSize.toString()}');
        txtSize -= 0.5;
        if (txtSize <= 0.1) {
          debugPrint('too small!');
          txtSize = 2;
          isInclude = true;
        }
      }
    } while (!isInclude);
    shape.number = PainterNumber(dx: x, dy: y, number: number, size: txtSize);
  }
}
