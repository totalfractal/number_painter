import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_line.dart';

class LinePainter extends CustomPainter {
  final List<ModelSvgLine> lines;

  const LinePainter({required this.lines});
  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.low
      ..color = Colors.black;
    debugPrint('lines');
    final sortedLines = _sortLines();
    final bigPathMap = <double, Path>{};
    for (final linesList in sortedLines.values) {
      final currentWidth = linesList[0].strokeWidth;
      debugPrint('big path stroke width = ${linesList[0].strokeWidth}');
      final bigPath = Path();
      for (final line in linesList) {
        final path = line.transformedPath;
        if (path != null) {
          bigPath.addPath(path, Offset.zero);
        }
      }
      bigPathMap[currentWidth] = bigPath;
    }
    for (var i = 0; i < bigPathMap.length; i++) {
      canvas.drawPath(bigPathMap.values.elementAt(i), _paint..strokeWidth = bigPathMap.keys.elementAt(i));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  //сортировка линий по размеру
  Map<double, List<ModelSvgLine>> _sortLines() {
    final sortedLines = <double, List<ModelSvgLine>>{};
    for (final line in lines) {
      if (sortedLines.containsKey(line.strokeWidth)) {
        sortedLines[line.strokeWidth]!.add(line);
      } else {
        sortedLines[line.strokeWidth] = [line];
      }
    }
    return sortedLines;
  }
}
