import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';

class CirclePainter extends CustomPainter {
  //final ValueNotifier<Offset> notifier;
  final Offset position;
  final SvgShapeModel selectedShape;
  final double radius;
  const CirclePainter({
    required this.position,
    required this.radius,
    required this.selectedShape,
  });
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..clipPath(selectedShape.transformedPath!)
      ..drawCircle(
        position,
        radius,
        Paint()
          ..color = selectedShape.fill
          ..style = PaintingStyle.fill,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
