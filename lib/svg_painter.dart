import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';
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
    if (!isInit) {
      if (size != _size) {
        debugPrint(size.toString());
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
          /* if (selected) {
            
            debugPrint('_getSelectedColor and selectedShape.id: $selectedColor  ${selectedShape!.id}');
            _paint
              ..color = HexColor(shape.fill)
              ..style = PaintingStyle.fill;
            selectedShape.isPainted = true;
          } else */
          {
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

      /* canvas.drawRect(
        textRect,
        Paint()
          ..color = Colors.orange
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.5,); */

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

    //TODO: попробовать отрисовывать один раз

    if (!isInit) {
      for (final line in lines) {
        final path = line.transformedPath;
        if (path != null) {
          canvas.drawPath(path, line.paint);
        }
      }
    }
  }

  void _addNumber(ModelSvgShape shape, int index, ui.Size size, ui.Canvas canvas) {
    final path = shape.transformedPath;
    final metrics = path!.computeMetrics();
    final bounds = path.getBounds();
    var txtSize = metrics.elementAt(0).length * .1;
    /* for (final metric in metrics) {
      txtSize += metric.length.toDouble();
    }
    txtSize *= 0.05; */

    // print(bounds.longestSide);

    var textRect = Rect.fromCenter(center: bounds.center - ui.Offset(txtSize / 5, -txtSize / 8), width: txtSize / 2, height: txtSize);
    var isInclude = false;

    var txtOffset = bounds.center;
    var x = bounds.topLeft.dx;
    var y = bounds.bottomRight.dy;
    do {
      for (var dx = x; dx < bounds.topRight.dx; dx += 1.0) {
        for (var dy = y; dy > bounds.topRight.dy; dy -= 1.0) {
          if (path.contains(Offset(dx.toDouble(), dy.toDouble()))) {
            textRect = Rect.fromCenter(
                center: ui.Offset(dx, dy) - ui.Offset(txtSize / 5, -txtSize / 8),
                width: (txtSize / 2) + (txtSize / 2),
                height: txtSize + txtSize / 2);
            for (var i = textRect.topLeft.dx; i < textRect.topRight.dx; i += 1.0) {
              for (var j = textRect.bottomRight.dy; j > textRect.topRight.dy; j -= 1.0) {
                if (path.contains(Offset(i, j))) {
                  isInclude = true;
                } else {
                  isInclude = false;
                  break;
                }
              }
              if (!isInclude) {
                break;
              }
            }
            if (!isInclude) {
              continue;
            } else {
              x = dx;
              y = dy;
              break;
            }
          } else {
            isInclude = false;
            continue;
          }
        }
        if (!isInclude) {
          continue;
        } else {
          /* debugPrint('include size: ${txtSize.toString()}');
          debugPrint('center: ${bounds.center}');
          debugPrint('included: $x,$y'); */
          txtOffset = ui.Offset(x, y);
          break;
        }
      }
      if (!isInclude) {
        //debugPrint('not include size: ${txtSize.toString()}');
        txtSize -= 0.5;
      }
    } while (!isInclude);

    canvas.drawRect(
      textRect,
      Paint()
        ..color = Colors.orange
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: txtSize,
    );
    final textSpan = TextSpan(
      text: '${index + 1}',
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
      ..paint(canvas, ui.Offset(txtOffset.dx - txtSize / 2, txtOffset.dy - txtSize / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ColoredPoint extends ui.Offset {
  final Color color;
  ColoredPoint(double x, double y, this.color) : super(x, y);
}
