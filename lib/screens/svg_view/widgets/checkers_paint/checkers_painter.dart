import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class CheckersPainter extends CustomPainter {
  const CheckersPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    Checkers(bgColor: Colors.grey[300]!, fgColor: Colors.grey[500]!, featuresCount: 100).paintOnCanvas(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
