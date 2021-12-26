import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';

class CirclePainter extends CustomPainter {
  final ValueNotifier<Offset> notifier;
  final double radius;
  const CirclePainter({
    required this.notifier,
    required this.radius,
  }) : super(repaint: notifier);
  @override
  void paint(Canvas canvas, Size size) {
    print('circle');
    canvas.clipRect(Offset.zero & size);
    canvas.drawCircle(
        notifier.value,
        radius,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
