import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:number_painter/main.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';
import 'package:number_painter/svg_painter.dart';

class ColoringPaint extends StatefulWidget {
  final ValueNotifier<ui.Offset> notifier;
  final List<ModelSvgShape> svgShapes;
  final List<ModelSvgShape>? selectedSvgShapes;
  final List<ModelSvgLine> svgLines;
  final int getSelectedColor;

  const ColoringPaint({
    required this.notifier,
    required this.svgShapes,
    required this.selectedSvgShapes,
    required this.svgLines,
    required this.getSelectedColor,
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
      painter:  SvgPainter(widget.notifier, widget.svgShapes, widget.selectedSvgShapes, widget.svgLines, widget.getSelectedColor, _isInit),
    );
  }
}