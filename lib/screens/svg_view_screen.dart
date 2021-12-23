import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
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

class _SvgViewScreenState extends State<SvgViewScreen> {
  final notifier = ValueNotifier(Offset.zero);

  final List<XmlElement> stringSvgPathShapes = [];
  final Iterable<XmlElement> _stringSvgPathLines = [];
  final List<ModelSvgShape> _svgShapes = [];
  List<ModelSvgShape>? _selectedSvgShapes;
  final List<ModelSvgLine> _svgLines = [];
  final Map<HexColor, List<ModelSvgShape>> _sortedShapes = {};
  late SvgPainter _svgPainter; //TODO: убрать late
  int _getSelectedColor = -1;
  bool _isInteract = true;
  bool _isInit = false;
  DrawableRoot? _svgRoot;

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
    _svgPainter = SvgPainter(notifier, _svgShapes, _selectedSvgShapes, _svgLines, _getSelectedColor, _isInit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          InteractiveViewer(
            onInteractionStart: !_isInteract ? (_) => setState(() => _isInteract = true) : null,
            onInteractionEnd: (_) => setState(() => _isInteract = _getSelectedColor != -1 ? false : true),
            maxScale: 10,
            child: GestureDetector(
              onLongPress: () => setState(() => _isInteract = true), // TODO: обработать в Listener

              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerUp: (e) {
                  setState(() {
                    if (!_isInteract) {
                      notifier.value = e.localPosition;
                    }
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: ColoringPaint(
                      notifier: notifier,
                      svgShapes: _svgShapes,
                      selectedSvgShapes: _selectedSvgShapes,
                      svgLines: _svgLines,
                      getSelectedColor: _getSelectedColor),
                ),
              ),
            ),
          ),
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

  void _callBackIndexColorOfColorPicker(int selectedColor) {
    setState(() {
      if (_getSelectedColor != selectedColor) {
        _getSelectedColor = selectedColor;
        _selectedSvgShapes = _sortedShapes.entries.elementAt(selectedColor).value;
        _isInteract = _getSelectedColor != -1 ? false : true;
      }
      debugPrint('_callBackIndexColorOfColorPicker: $_getSelectedColor');
    });
  }

  Map<HexColor, List<ModelSvgShape>> _getSortedShapes(List<ModelSvgShape> shapes) {
    final sortedShapes = <HexColor, List<ModelSvgShape>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(HexColor(shape.fill))) {
        sortedShapes[HexColor(shape.fill)]!.add(shape);
      } else {
        sortedShapes[HexColor(shape.fill)] = [shape];
      }
    }
    return sortedShapes;
  }
}
