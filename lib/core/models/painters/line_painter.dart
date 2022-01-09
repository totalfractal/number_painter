import 'package:flutter/material.dart';
import 'package:number_painter/core/models/model_svg_line.dart';

class LinePainter extends CustomPainter {
  final List<ModelSvgLine> lines;

  const LinePainter({required this.lines});
  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('lines');
    //canvas.clipRect(Offset.zero & size);
    for (final line in lines) {
      final path = line.transformedPath;
      if (path != null) {
        canvas.drawPath(path, line.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
