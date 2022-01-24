import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/svg_line_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';

///Отвечает за отрисовку закрашенных областей
class ShapePainter extends CustomPainter {
  final List<SvgLineModel> lines;
  final Map<Color, List<SvgShapeModel>> sortedShapes;
  final ValueNotifier<Offset> notifier;
  final bool isInit;
  final List<SvgShapeModel> shapes;
  final Offset center;
  final Paint _paint = Paint();
  List<SvgShapeModel>? selectedShapes;
  Color? selectedColor;

  ShapePainter({
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
    canvas.clipRect(Offset.zero & size);
    SvgShapeModel? selectedShape;
    for (final shape in shapes) {
      final path = shape.transformedPath;
      if (shape.isPicked) {
        if (shape.isPainted) {
          _paint
            ..color = shape.fill
            ..style = PaintingStyle.fill;
          canvas.drawPath(path!, _paint);
        } else {
          final selected = path!.contains(notifier.value);
          selectedShape ??= selected ? shape : null;
        }
      } else {
        if (shape.isPainted) {
          _paint
            ..color = shape.fill
            ..style = PaintingStyle.fill;
          canvas.drawPath(path!, _paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
