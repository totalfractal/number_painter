import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/main.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';
import 'package:number_painter/svg_painter.dart';

class ColoringPaint extends StatefulWidget {
  final ValueNotifier<ui.Offset> notifier;
  final List<ModelSvgShape> svgShapes;
  final List<ModelSvgShape>? selectedSvgShapes;
  final Map<HexColor, List<ModelSvgShape>> sortedShapes;
  final List<ModelSvgLine> svgLines;
  final ui.Color? getSelectedColor;

  const ColoringPaint({
    required this.notifier,
    required this.svgShapes,
    required this.selectedSvgShapes,
    required this.svgLines,
    required this.getSelectedColor,
    required this.sortedShapes,
    Key? key,
  }) : super(key: key);

  @override
  State<ColoringPaint> createState() => _ColoringPaintState();
}

class _ColoringPaintState extends State<ColoringPaint> {
  final bool _isInit = false; //TODO: на подумать

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SvgPainter(
        notifier: widget.notifier,
        shapes: widget.svgShapes,
        selectedShapes: widget.selectedSvgShapes,
        lines: widget.svgLines,
        sortedShapes: widget.sortedShapes,
        selectedColor: widget.getSelectedColor,
        isInit: _isInit,
      ),
    );
  }
}
