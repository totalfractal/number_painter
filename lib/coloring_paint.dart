import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:number_painter/main.dart';

class ColoringPainter extends StatefulWidget {
  const ColoringPainter({
    Key? key,
    required this.notifier,
    required this.svgShapes,
    required this.svgLines,
    required this.getSelectedColor,
  }) : super(key: key);

  final ValueNotifier<ui.Offset> notifier;
  final List<ModelSvgShape> svgShapes;
  final List<ModelSvgLine> svgLines;
  final int getSelectedColor;

  @override
  State<ColoringPainter> createState() => _ColoringPainterState();
}

class _ColoringPainterState extends State<ColoringPainter> {
  final bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:  SvgPainterPath(widget.notifier, widget.svgShapes, widget.svgLines, widget.getSelectedColor, _isInit),
    );
  }
}