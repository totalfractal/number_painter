import 'package:flutter/material.dart';
import 'package:number_painter/core/models/coloring_shape.dart';
import 'package:number_painter/core/painter_tools.dart';
import 'package:number_painter/screens/svg_view/widgets/circle_paint/circle_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/color_picker/color_picker.dart';
import 'package:number_painter/screens/svg_view/widgets/painter_inherited.dart';

class ManyCirclesPaint extends StatelessWidget {
  final ValueNotifier<Offset> notifier;
  final List<ColoringShape> selectedColoredShapes;
  final AnimationController percentController;
  final GlobalKey<ColorPickerState> colorListKey;
  final VoidCallback onEndCircle;
  const ManyCirclesPaint({
    required this.notifier,
    required this.selectedColoredShapes,
    required this.percentController,
    required this.colorListKey,
    required this.onEndCircle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final shape in selectedColoredShapes)
          SingleCirclePaint(
            percentController: percentController,
            coloringShape: shape,
            colorListKey: colorListKey,
            onEndCircle: onEndCircle,
          ),
      ],
    );
  }
}

class SingleCirclePaint extends StatefulWidget {
  final ColoringShape coloringShape;
  final AnimationController percentController;
  final GlobalKey<ColorPickerState> colorListKey;
  final VoidCallback onEndCircle;
  const SingleCirclePaint({
    required this.coloringShape,
    required this.percentController,
    required this.colorListKey,
    required this.onEndCircle,
    Key? key,
  }) : super(key: key);

  @override
  State<SingleCirclePaint> createState() => _SingleCirclePaintState();
}

class _SingleCirclePaintState extends State<SingleCirclePaint> with SingleTickerProviderStateMixin {
  //Находим InheritedWidget, в котором лежат данные
  late final _painterInherited = PainterInherited.of(context);
  late final _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
    ..addListener(_listener)
    //После анимации закрашивания помечаем фигуру как закрашенную и сохраняем прогресс в БД
    ..forward().then((value) {
      //Считаем процент до окрашивания
      final oldPercent = _painterInherited.selectedShapes.where((shape) => shape.isPainted).length / _painterInherited.selectedShapes.length;
      //"Осторожно, окрашено" :)
      widget.coloringShape.shape.isPainted = true;
      //Рассчитываем процент после закрашивания
      final currentPercent = _painterInherited.selectedShapes.where((shape) => shape.isPainted).length / _painterInherited.selectedShapes.length;
      //Передаем эти проценты в ColorPicker
      widget.colorListKey.currentState!.setPercent(oldPercent, currentPercent);
      //Запускаем анимацию процентов в ColorItem
      widget.percentController.forward(from: 0).then((_) {
        //Удаляем цвет из пикера, если он выполнен на 100 процентов
        if (currentPercent == 1) {
          widget.colorListKey.currentState!.remove(widget.coloringShape.shape.fill);
        }
      });

      //join нужен для сохранения в формате TEXT в БД
      _painterInherited.painterProgress.shapes = _painterInherited.svgShapes.join(' ');
      //Собственно сохраняем в БД
      PainterTools.dbProvider.updatePainter(_painterInherited.painterProgress);
      //Коллбек после раскраски
      widget.onEndCircle();
    });

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CirclePainter(
          position: widget.coloringShape.cicrclePosition,
          // Радиус круга равен самой длиной стороне Rect данного Path
          radius: _animationController.value * widget.coloringShape.shape.transformedPath!.getBounds().longestSide,
          selectedShape: widget.coloringShape.shape,
        ),
      ),
    );
  }

  void _listener() => setState(() {});
}
