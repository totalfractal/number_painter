import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class ShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final Pattern pattern = Checkers(bgColor: Colors.lightGreenAccent, fgColor: Colors.black, featuresCount: 100);
    pattern.paintOnCanvas(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
