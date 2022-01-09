import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class RadialPainter extends CustomPainter {
  final Color lineColor;
  final double width;
  final double currentPercent;

  RadialPainter({
    required this.lineColor,
    required this.width,
    required this.currentPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final completedLine = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    //final oldSweepAngle = pi * 2 * oldPercent;
    final sweepAngle = pi * 2 * currentPercent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      completedLine,
    );
    // print(currentPercent);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
