import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/core/models/model_svg_line.dart';
import 'package:number_painter/core/models/model_svg_shape.dart';
import 'dart:math' as math;

Size _size = Size.infinite;

//TODO: разобраться с инкапсуляцией
class SvgPainter extends CustomPainter {
  final List<ModelSvgShape> shapes;
  List<ModelSvgShape>? selectedShapes;
  final List<ModelSvgLine> lines;
  final Map<Color, List<ModelSvgShape>> sortedShapes;
  final ValueNotifier<Offset> notifier;
  final bool isInit;
  final Paint _paint = Paint();
  Color? selectedColor;
  final Offset center;
  //Size _size = Size.infinite;
  SvgPainter({
    required this.notifier,
    required this.shapes,
    required this.selectedShapes,
    required this.lines,
    required this.sortedShapes,
    required this.selectedColor,
    required this.isInit,
    required this.center,
  }) : super(repaint: null);

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('shapes');

    canvas.clipRect(Offset.zero & size);

    ModelSvgShape? selectedShape;
    for (final shape in shapes) {
      final path = shape.transformedPath;
      if (shape.isPicked) {
        if (shape.isPainted) {
          _paint
            ..color = shape.fill
            ..style = PaintingStyle.fill;
        } else {
          //_addNumber(shape, shape.sortedId, size, canvas);
          final selected = path!.contains(notifier.value);
          selectedShape ??= selected ? shape : null;
          if (selected) {
            debugPrint('_getSelectedColor and selectedShape.id: $selectedColor  ${selectedShape!.id}');
            _paint
              ..color = shape.fill
              ..style = PaintingStyle.fill;
            selectedShape.isPainted = true;
          } else {
            _paint
              ..color = Colors.transparent
              ..style = PaintingStyle.fill;
          }
        }
      } else {
        if (shape.isPainted) {
          _paint
            ..color = shape.fill
            ..style = PaintingStyle.fill;
        } else {
          _paint
            ..color = Colors.white
            ..style = PaintingStyle.fill;
        }
      }
      canvas.drawPath(path!, _paint);

      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: shape.number.size,
      );
      final textSpan = TextSpan(
        text: '${shape.number.number + 1}',
        style: textStyle,
      );
      TextPainter(
        textAlign: ui.TextAlign.center,
        text: textSpan,
        textDirection: TextDirection.ltr,
      )
        ..layout(
          minWidth: 0,
          maxWidth: size.width,
        )
        ..paint(canvas, ui.Offset(shape.number.dx - shape.number.size / 2, shape.number.dy - shape.number.size / 2));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


