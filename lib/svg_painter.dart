import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/models/model_svg_line.dart';
import 'package:number_painter/models/model_svg_shape.dart';

//TODO: разобраться с инкапсуляцией
class SvgPainter extends CustomPainter {
  final List<ModelSvgShape> _shapes;
  final List<ModelSvgShape>? _selectedShapes;
  final List<ModelSvgLine> _lines;
  final ValueNotifier<Offset> _notifier;
  final Paint _paint = Paint();
  final bool _isInit;
  Size _size = Size.infinite;
  int _getSelectedColor;
  SvgPainter(this._notifier, this._shapes, this._selectedShapes, this._lines, this._getSelectedColor, this._isInit) : super(repaint: _notifier);

  @override
  void paint(Canvas canvas, Size size) {
    if (!_isInit) {
      if (size != _size) {
        _size = size;
        final fs = applyBoxFit(BoxFit.contain, Size(3000, 3000), size);
        final r = Alignment.center.inscribe(fs.destination, Offset.zero & size);
        final matrix = Matrix4.translationValues(r.left, r.top, 0)..scale(fs.destination.width / fs.source.width);
        for (final shape in _shapes) {
          shape.transform(matrix);
        }
        for (final shape in _lines) {
          shape.transform(matrix);
        }
      }
    }

    canvas
      ..clipRect(Offset.zero & size)
      ..drawColor(Colors.white, BlendMode.screen);
    ModelSvgShape? selectedShape;

    for (final shape in _shapes) {
      final path = shape.transformedPath;
      if (shape.isPainted){
        _paint
          ..color = HexColor(shape.fill)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path!, _paint);
      }
      final selected = path!.contains(_notifier.value);
      //final hex = Color(int.parse(shape.fill.replaceAll('#', '0x')));
      selectedShape ??= selected ? shape : null;
      

      if (selected) {
        debugPrint("_getSelectedColor and selectedShape.id: $_getSelectedColor  ${selectedShape!.id}");
        _paint
          ..color = HexColor(shape.fill)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, _paint);
        selectedShape.isPainted = true;
      }

      final bounds = path.getBounds();
      final txtSize = bounds.width * 0.10;
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: txtSize,
      );
      final textSpan = TextSpan(
        text: shape.id,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, bounds.center);
    }
    //TODO: попробовать отрисовывать один раз
    if (!_isInit) {
      for (final line in _lines) {
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

    /* for (var line in _getPathSvgModel.where((element) => element.strokeWidth != null)) {
      debugPrint('line');
      final path = line._transformedPath;
      _paint
        ..color = HexColor("#1A171B")
        ..strokeWidth = line.strokeWidth!
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path!, _paint);
    } */

    if (selectedShape != null) {
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
      canvas.drawParagraph(paragraph, _notifier.value.translate(0, 0));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
