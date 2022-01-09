import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';

class ShapeStrokePainter extends CustomPainter {
  final List<ModelSvgShape> shapes;
  

  const ShapeStrokePainter({required this.shapes});
  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 0
    ..filterQuality = FilterQuality.low
    ..color = Colors.black;
    debugPrint('lines');
    //canvas.clipRect(Offset.zero & size);
    for (final shape in shapes) {
      final path = shape.transformedPath;
      if (path != null) {
        canvas.drawPath(path, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

