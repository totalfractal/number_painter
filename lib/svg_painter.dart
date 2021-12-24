import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';

//TODO: разобраться с инкапсуляцией
class SvgPainter extends CustomPainter {
  final List<ModelSvgShape> shapes;
  List<ModelSvgShape>? selectedShapes;
  final List<ModelSvgLine> lines;
  final Map<HexColor, List<ModelSvgShape>> sortedShapes;
  final ValueNotifier<Offset> notifier;
  final bool isInit;
  final Paint _paint = Paint();
  Color? selectedColor;
  Size _size = Size.infinite;
  SvgPainter({
    required this.notifier,
    required this.shapes,
    required this.selectedShapes,
    required this.lines,
    required this.sortedShapes,
    required this.selectedColor,
    required this.isInit,
  }) : super(repaint: null);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isInit) {
      if (size != _size) {
        _size = size;
        final fs = applyBoxFit(BoxFit.contain, const Size(3000, 3000), size);
        final r = Alignment.center.inscribe(fs.destination, Offset.zero & size);
        final matrix = Matrix4.translationValues(r.left, r.top, 0)..scale(fs.destination.width / fs.source.width);
        for (final shape in shapes) {
          shape.transform(matrix);
        }
        for (final shape in lines) {
          shape.transform(matrix);
        }
      }
    }

    canvas.clipRect(Offset.zero & size);

    ModelSvgShape? selectedShape;
    /* if (selectedShapes != null) {
      for (final selectedShape in selectedShapes!) {
        final path = selectedShape.transformedPath;
        _paint
          ..color = Colors.transparent
          ..style = PaintingStyle.fill;
        canvas.drawPath(path!, _paint);
      }
      for (var i = 0; i < sortedShapes.entries.length; i++) {
        final sortedPair = sortedShapes.entries.elementAt(i);

        for (final shape in sortedPair.value) {
          final path = shape.transformedPath;
          _addNumber(shape, i, size, canvas);
          _paint
            ..color = HexColor("#1A171B")
            ..strokeWidth = 0
            ..style = PaintingStyle.stroke;

          canvas.drawPath(path!, _paint);
          if (sortedPair.key != selectedColor) {
            if (!shape.isPainted) {
              _paint
                ..color = Colors.white
                ..style = PaintingStyle.fill;
              canvas.drawPath(path!, _paint);
            }
          }
        }
      }
    } */
    for (final shape in shapes) {
      final path = shape.transformedPath;
      if (shape.isPicked) {
        if (shape.isPainted) {
          _paint
            ..color = HexColor(shape.fill)
            ..style = PaintingStyle.fill;
        } else {
          final selected = path!.contains(notifier.value);
          selectedShape ??= selected ? shape : null;
          if (selected) {
            debugPrint('_getSelectedColor and selectedShape.id: $selectedColor  ${selectedShape!.id}');
            _paint
              ..color = HexColor(shape.fill)
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
            ..color = HexColor(shape.fill)
            ..style = PaintingStyle.fill;
        } else {
            _paint
              ..color = Colors.white
              ..style = PaintingStyle.fill;
          
        }
      }
      canvas.drawPath(path!, _paint);
    }
    /* for (var i = 0; i < sortedShapes.entries.length; i++) {
      final sortedPair = sortedShapes.entries.elementAt(i);
      for (final shape in sortedPair.value) {
        final path = shape.transformedPath;
        if (shape.isPainted) {
          _paint
            ..color = HexColor(shape.fill)
            ..style = PaintingStyle.fill;
          canvas.drawPath(path!, _paint);
        }

        final selected = path!.contains(notifier.value);
        selectedShape ??= selected ? shape : null;

        if (selected) {
          debugPrint("_getSelectedColor and selectedShape.id: $selectedColor  ${selectedShape!.id}");
          _paint
            ..color = HexColor(shape.fill)
            ..style = PaintingStyle.fill;
          canvas.drawPath(path, _paint);
          selectedShape.isPainted = true;
        }
        if (!shape.isPainted) {
          final metrics = path.computeMetrics();
          final bounds = path.getBounds();
          final txtSize = metrics.elementAt(0).length * 0.05;
          final textStyle = TextStyle(
            color: Colors.black,
            fontSize: txtSize,
          );
          final textSpan = TextSpan(
            text: '${i + 1}',
            style: textStyle,
          );
          TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          )
            ..layout(
              minWidth: 0,
              maxWidth: size.width,
            )
            ..paint(canvas, bounds.center);
        }
      }
    } */

    //TODO: попробовать отрисовывать один раз
    if (!isInit) {
      for (final line in lines) {
        final path = line.transformedPath;
        if (path != null) {
          _paint
            ..color = HexColor("#1A171B")
            ..strokeWidth = 0
            ..style = PaintingStyle.stroke;

          canvas.drawPath(path, _paint);
        }
      }
    }

    /*  if (selectedShape != null) {
      _paint
        ..color = Colors.black
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12)
        ..style = PaintingStyle.fill;
      canvas.drawPath(selectedShape.transformedPath!, _paint);
      _paint.maskFilter = null;

      final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: 40,
        fontFamily: 'Roboto',
      ))
        ..pushStyle(ui.TextStyle(
          color: Colors.black,
        ))
        ..addText(selectedShape.id);
      final paragraph = builder.build()..layout(ui.ParagraphConstraints(width: size.width));
      canvas.drawParagraph(paragraph, notifier.value.translate(0, 0));
    } */
  }

  void _addNumber(ModelSvgShape shape, int i, ui.Size size, ui.Canvas canvas) {
    final path = shape.transformedPath;
    final metrics = path!.computeMetrics();
    final bounds = path.getBounds();
    final txtSize = metrics.elementAt(0).length * 0.05;
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: txtSize,
    );
    final textSpan = TextSpan(
      text: '${i + 1}',
      style: textStyle,
    );
    TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )
      ..layout(
        minWidth: 0,
        maxWidth: size.width,
      )
      ..paint(canvas, bounds.center);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
