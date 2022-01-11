import 'package:flutter/material.dart';
import 'package:number_painter/core/models/coloring_shape.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/screens/svg_view/widgets/circle_painter.dart';

class ManyCirclesPaint extends StatefulWidget {
  final ValueNotifier<Offset> notifier;
  final List<ColoringShape> selectedColoredShapes;
  const ManyCirclesPaint({
    required this.notifier,
    required this.selectedColoredShapes,
    Key? key,
  }) : super(key: key);

  @override
  State<ManyCirclesPaint> createState() => _ManyCirclesPaintState();
}

class _ManyCirclesPaintState extends State<ManyCirclesPaint> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final shape in widget.selectedColoredShapes)
          SingleCirclePaint(
            shape: shape,
          ),
      ],
    );
  }
}

class SingleCirclePaint extends StatefulWidget {
  final ColoringShape shape;
  const SingleCirclePaint({
    required this.shape,
    Key? key,
  }) : super(key: key);

  @override
  State<SingleCirclePaint> createState() => _SingleCirclePaintState();
}

class _SingleCirclePaintState extends State<SingleCirclePaint> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)
    ..addListener(_listener)
    ..forward();

  @override
  void dispose() {
    _animationController..removeListener(_listener)..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CirclePainter(
          position: widget.shape.cicrclePosition,
          // Радиус круга равен самой длиной стороне Rect данного Path
          radius: _animationController.value * widget.shape.shape.transformedPath!.getBounds().longestSide,
          selectedShape: widget.shape.shape,
        ),
      ),
    );
  }

  void _listener() => setState(() {});
}
