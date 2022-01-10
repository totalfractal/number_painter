import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';
import 'package:number_painter/screens/svg_view/widgets/circle_painter.dart';

class CirclePaint extends StatefulWidget {
  final ValueNotifier<Offset> notifier;
  final AnimationController fillController;
  final SvgShapeModel selectedShape;
  const CirclePaint({
    required this.notifier,
    required this.fillController,
    required this.selectedShape,
    Key? key,
  }) : super(key: key);

  @override
  State<CirclePaint> createState() => _CirclePaintState();
}

class _CirclePaintState extends State<CirclePaint> {
  @override
  void initState() {
    super.initState();
    widget.fillController.addListener(_fillControllerListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.fillController.removeListener(_fillControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CirclePainter(
          notifier: widget.notifier,
          // Радиус круга равен самой длиной стороне Rect данного Path
          radius: widget.fillController.value * widget.selectedShape.transformedPath!.getBounds().longestSide,
          selectedShape: widget.selectedShape,
        ),
      ),
    );
  }

  void _fillControllerListener() => setState(() {});
}
