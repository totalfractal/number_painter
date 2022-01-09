import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class CirclePainter extends CustomPainter {
  final ValueNotifier<Offset> notifier;
  final ModelSvgShape selectedShape;
  final double radius;
  const CirclePainter({
    required this.notifier,
    required this.radius,
    required this.selectedShape,
  }) : super(repaint: notifier);
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..clipPath(selectedShape.transformedPath!)
      ..drawCircle(
          notifier.value,
          radius,
          Paint()
            ..color = selectedShape.fill
            ..style = PaintingStyle.fill,);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
