import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class RadialPainter extends CustomPainter {
  final Color bgColor;
  final Color lineColor;
  final double width;
  final double percent;

  RadialPainter({required this.bgColor, required this.lineColor, required this.width, required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final bgLine = Paint()
      ..color = bgColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final completedLine = Paint()
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final sweepAngle = 2 * pi * percent;
    canvas
      ..drawCircle(center, radius, bgLine)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        sweepAngle,
        false,
        completedLine,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
