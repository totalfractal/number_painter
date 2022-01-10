import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';

class ShapeStrokePainter extends CustomPainter {
  final List<SvgShapeModel> shapes;

  ShapeStrokePainter({required this.shapes});
  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('lines');
    //canvas.clipRect(Offset.zero & size);
    for (final shape in shapes) {
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: shape.number.size,
      );
      final textSpan = TextSpan(
        text: '${shape.number.number + 1}',
        style: textStyle,
      );
      TextPainter(
        textAlign: TextAlign.center,
        text: textSpan,
        textDirection: TextDirection.ltr,
      )
        ..layout(
          minWidth: 0.5,
          maxWidth: size.width,
        )
        ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

