import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/screens/svg_view/widgets/fade_painter.dart';

class FadePaint extends StatefulWidget {
  final AnimationController fadeController;
  final List<SvgShapeModel> selectedSvgShapes;
  const FadePaint({
    required this.fadeController,
    required this.selectedSvgShapes,
    Key? key,
  }) : super(key: key);

  @override
  State<FadePaint> createState() => _FadePaintState();
}

class _FadePaintState extends State<FadePaint> {
  @override
  void initState() {
    super.initState();
    widget.fadeController.addListener(_fadeControllerListener);
  }

  @override
  void dispose() {
    widget.fadeController.removeListener(_fadeControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: FadePainter(animation: widget.fadeController, selectedShapes: widget.selectedSvgShapes),
      ),
    );
  }

  void _fadeControllerListener() => setState(() {});
}
