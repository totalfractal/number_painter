import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/checkers_painter.dart';
import 'package:number_painter/circle_painer.dart';
import 'package:number_painter/custom_clipper.dart';
import 'package:number_painter/fade_painter.dart';
import 'package:number_painter/widgets/color_picker.dart';
import 'package:number_painter/widgets/coloring_paint.dart';
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
  List<ModelSvgShape> _selectedSvgShapes = [];
  //Path _selectedPath = Path();
  ModelSvgShape _selectedShape = ModelSvgShape.epmty();
  final List<ModelSvgLine> _svgLines = [];
  final Map<HexColor, List<ModelSvgShape>> _sortedShapes = {};
  Color? _getSelectedColor;
  bool _isInteract = false;
  bool _isInit = false;

  late final AnimationController _fadeController = AnimationController(
    duration: Duration(milliseconds: 1000),
    vsync: this,
  )..addListener(() => setState(() {}));

  late final AnimationController _fillController = AnimationController(
    duration: Duration(milliseconds: 1000),
    vsync: this,
  )..addListener(() => setState(() {}));

  @override
  void initState() {
    super.initState();
    stringSvgPathShapes.addAll((XmlDocument.parse(stringSvg).findAllElements('path')).toList());
    for (final itemPath in stringSvgPathShapes) {
      if (itemPath.toString().contains('fill')) {
        _svgShapes.add(ModelSvgShape.fromElement(itemPath));
      }
      if (itemPath.toString().contains('stroke')) {
        _svgLines.add(ModelSvgLine.fromElement(itemPath));
      }
    }
    _sortedShapes.addAll(_getSortedShapes(_svgShapes));
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
            maxScale: 10,
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
                                setState(() {
                                  _selectedShape = shape;
                                  notifier.value = e.localPosition;
                                  _isInteract = true;
                                });
                                _fillController.forward().then((_) {
                                  _selectedShape.isPainted = true;
                                  _isInteract = false;
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

  Map<HexColor, List<ModelSvgShape>> _getSortedShapes(List<ModelSvgShape> shapes) {
    final sortedShapes = <HexColor, List<ModelSvgShape>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(shape.fill)) {
        sortedShapes[shape.fill]!.add(shape);
        shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      } else {
        sortedShapes[shape.fill] = [shape];
        shape.sortedId = sortedShapes.keys.toList().indexOf(shape.fill);
      }
    }
    return sortedShapes;
  }
}
