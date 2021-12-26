import 'package:flutter/material.dart';
import 'package:number_painter/models/model_svg_shape.dart';

class FadePainter extends CustomPainter {
  final List<ModelSvgShape> selectedShapes;
  final Animation<Color?> _color;
  final Paint _paint = Paint();
  FadePainter({required Animation<double> animation, required this.selectedShapes})
      : _color = ColorTween(begin: Colors.white, end: Colors.white.withAlpha(0)).animate(animation),
        super(repaint: animation);
  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in selectedShapes) {
      _paint
        ..color = _color.value!
        ..blendMode = BlendMode.plus
        ..style = PaintingStyle.fill;
      canvas.drawPath(shape.transformedPath!, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
