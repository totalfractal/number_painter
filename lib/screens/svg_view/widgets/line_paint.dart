
import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_line.dart';
import 'package:number_painter/screens/svg_view/widgets/line_painter.dart';

class LinePaint extends StatelessWidget {
  final List<SvgLineModel> svgLines;
  const LinePaint({
    required this.svgLines,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        painter: LinePainter(lines: svgLines),
      ),
    );
  }
}