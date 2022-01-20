import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';

class NumberPainter extends CustomPainter {
  final List<SvgShapeModel> shapes;
  final double scale;

  NumberPainter({ required this.shapes, required this.scale});
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
    //canvas.clipRect(Offset.zero & size);
    for (final shape in shapes) {
      /* canvas.drawPoints(
          PointMode.points,
          [Offset(shape.number.dx, shape.number.dy)],
          Paint()
            ..color = Colors.redAccent
            ..strokeWidth = 1
            ..style = PaintingStyle.fill); */
      //canvas.drawRect(Offset(shape.number.dx, shape.number.dy) & Size(shape.number.size/2, shape.number.size), Paint()..color = Colors.redAccent..strokeWidth = 1..style = PaintingStyle.stroke);
      if (scale > 1 && shape.number.size >= 10 && shape.number.size <= 16) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 2 && shape.number.size >= 8 && shape.number.size < 10) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 3 && shape.number.size >= 6 && shape.number.size < 8) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 4 && shape.number.size >= 5 && shape.number.size < 6) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 5 && shape.number.size >= 4 && shape.number.size < 5) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 6 && shape.number.size >= 3 && shape.number.size < 4) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }

      if (scale > 8 && shape.number.size >= 2 && shape.number.size < 3) {
        final textStyle = TextStyle(
          color: Colors.black,
          fontSize: shape.number.size,
        );
        final textSpan = TextSpan(
          text: '${shape.number.number + 1}',
          style: textStyle,
        );

        textPainter
          ..text = textSpan
          ..layout(
            minWidth: 0.5,
            maxWidth: 100,
          )
          ..paint(canvas, Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
