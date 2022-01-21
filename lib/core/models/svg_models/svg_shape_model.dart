import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class SvgShapeModel {
  final String id;
  final String d;
  final Color fill;
  //final List<ModelSvgShape> listModelSvgFile;
  final Path _path;
  //int sortedId = -1;
  PainterNumber number = PainterNumber(dx: 0, dy: 0, number: -1, size: 0);
  bool isPainted = false;
  bool isPicked = false;
  Path? transformedPath;
  SvgShapeModel._(
    this.id,
    this.d,
    this.fill,
    //this.listModelSvgFile,
  ) : _path = parseSvgPathData(d);

  factory SvgShapeModel.fromElement(XmlElement svgElement) {
    return SvgShapeModel._(
      svgElement.getAttribute('id').toString(),
      svgElement.getAttribute('d').toString(),
      HexColor(svgElement.getAttribute('fill').toString() == 'black' ? '#FF0000' : svgElement.getAttribute('fill').toString()),
      //svgElement.findElements('path').map<ModelSvgShape>((e) => ModelSvgShape.fromElement(e)).toList(),
    );
  }

  factory SvgShapeModel.epmty() {
    return SvgShapeModel._(
      '',
      '',
      HexColor('FF000000'),
      //[],
    );
  }

  @override
  String toString() {
    return '$id,$isPainted';
  }

  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) => transformedPath = _path.transform(matrix.storage);

  void setNumberProperties(int num) {
    final path = transformedPath;
    final metrics = path!.computeMetrics();
    final bounds = path.getBounds();
    var txtSize = 16.0;
    //debugPrint(txtSize.toString());
    /* for (final metric in metrics) {
      txtSize += metric.length.toDouble();q
    }
    txtSize *= 0.05; */

    // print(bounds.longestSide);

    var textRect = Rect.fromCenter(center: bounds.center - Offset(txtSize / 5, -txtSize / 8), width: txtSize / 2, height: txtSize);
    var isInclude = false;

    var txtOffset = bounds.center;
    var x = bounds.topLeft.dx;
    var y = bounds.bottomRight.dy;
    do {
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
      );
      final textStyle = TextStyle(
        color: Colors.black,
        fontSize: txtSize,
      );
      final textSpan = TextSpan(
        text: '${num + 1}',
        style: textStyle,
      );
      textPainter
        ..text = textSpan
        ..layout(
          minWidth: 0.5,
          maxWidth: 100,
        );
      for (var dx = x; dx < bounds.topRight.dx; dx += 1.0) {
        for (var dy = y; dy > bounds.topRight.dy; dy -= 1.0) {
          if (path.contains(Offset(dx.toDouble(), dy.toDouble()))) {
            textRect = Rect.fromCenter(
              center: Offset(dx, dy) /* - Offset(txtSize / 5, -txtSize / 8) */,
              width: textPainter.width + 3,
              height: textPainter.height + 3,
            );
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
          debugPrint('include size: ${txtSize.toString()}');
          /* debugPrint('center: ${bounds.center}');
          debugPrint('included: $x,$y'); */
          txtOffset = Offset(x, y);
          break;
        }
      }
      if (!isInclude) {
        //debugPrint('not include size: ${txtSize.toString()}');
        txtSize -= 0.5;
        if (txtSize <= 0.1) {
          isInclude = true;
          txtSize = 1;
        }
      }
    } while (!isInclude);
    number = PainterNumber(dx: x, dy: y, number: num, size: txtSize);
  }
}

class PainterNumber extends Offset {
  final int number;
  final double size;
  PainterNumber({required double dx, required double dy, required this.number, required this.size}) : super(dx, dy);
}
