import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class RadialPainter extends CustomPainter {
  final Color bgColor;
  final Color lineColor;
  final double width;
  final double oldPercent;
  final double currentPercent;
  final Animation<double> _percent;

  RadialPainter({
    required this.bgColor,
    required this.lineColor,
    required this.width,
    required this.oldPercent,
    required this.currentPercent,
    required Animation<double> animation,
  })  : _percent = Tween<double>(begin: 0, end: currentPercent).animate(animation),
        super(repaint: animation);

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
    final oldSweepAngle = pi * 2 * oldPercent;
    final sweepAngle = pi * 2 * _percent.value;

    canvas
      ..drawCircle(center, radius, bgLine)
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        oldSweepAngle,
        false,
        completedLine,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        sweepAngle,
        false,
        completedLine,
      );
    print(oldPercent);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
