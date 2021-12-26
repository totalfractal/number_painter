import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/checkers_painter.dart';
import 'package:number_painter/circle_painer.dart';
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

class _SvgViewScreenState extends State<SvgViewScreen> with SingleTickerProviderStateMixin {
  final notifier = ValueNotifier(Offset.zero);

  final List<XmlElement> stringSvgPathShapes = [];
  final Iterable<XmlElement> _stringSvgPathLines = [];
  final List<ModelSvgShape> _svgShapes = [];
  List<ModelSvgShape>? _selectedSvgShapes;
  final List<ModelSvgLine> _svgLines = [];
  final Map<HexColor, List<ModelSvgShape>> _sortedShapes = {};
  Color? _getSelectedColor;
  bool _isInteract = false;
  bool _isInit = false;

  late final AnimationController _controller0 = AnimationController(
    duration: Duration(milliseconds: 2000),
    vsync: this,
    value: 0,
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
            onInteractionStart: !_isInteract ? (_) => setState(() => _isInteract = true) : null,
            onInteractionEnd: (_) => setState(() => _isInteract = _getSelectedColor == null ),
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
                    painter: CirclePainter(notifier: notifier, radius: _controller0.value * 100),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: //SvgPicture.string(stringSvg),
                      Listener(
                    onPointerUp: (e) {
                      if (_isInteract) {
                        _controller0.reset();
                        setState(() {
                          notifier.value = e.localPosition;
                        });
                        _controller0.fling(velocity: 0.1);
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
        _getSelectedColor = selectedColor;
        _selectedSvgShapes = _sortedShapes[selectedColor];
        for (final shape in _svgShapes) {
          if (HexColor(shape.fill) == _getSelectedColor) {
            shape.isPicked = true;
          } else {
            shape.isPicked = false;
          }
        }
        _isInteract = _getSelectedColor == null;
      }
      debugPrint('_callBackIndexColorOfColorPicker: $_getSelectedColor');
    });
  }

  Map<HexColor, List<ModelSvgShape>> _getSortedShapes(List<ModelSvgShape> shapes) {
    final sortedShapes = <HexColor, List<ModelSvgShape>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(HexColor(shape.fill))) {
        sortedShapes[HexColor(shape.fill)]!.add(shape);
        shape.sortedId = sortedShapes.keys.toList().indexOf(HexColor(shape.fill));
      } else {
        sortedShapes[HexColor(shape.fill)] = [shape];
        shape.sortedId = sortedShapes.keys.toList().indexOf(HexColor(shape.fill));
      }
    }
    return sortedShapes;
  }
}
