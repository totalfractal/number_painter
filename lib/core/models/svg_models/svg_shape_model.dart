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
    this.isPainted,
    //this.listModelSvgFile,
  ) : _path = parseSvgPathData(d);

  factory SvgShapeModel.fromElement(XmlElement svgElement) {
    return SvgShapeModel._(
      svgElement.getAttribute('id').toString(),
      svgElement.getAttribute('d').toString(),
      HexColor(svgElement.getAttribute('fill').toString() == 'black' ? '#000000' : svgElement.getAttribute('fill').toString()),
      //svgElement.findElements('path').map<ModelSvgShape>((e) => ModelSvgShape.fromElement(e)).toList(),
      svgElement.getAttribute('fill').toString() == 'black',
    );
  }

  factory SvgShapeModel.epmty() {
    return SvgShapeModel._(
      '',
      '',
      HexColor('FF000000'),
      false,
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
    final bounds = path!.getBounds();
    var txtSize = 16.0;

    var textRect = Rect.fromCenter(center: bounds.center - Offset(txtSize / 5, -txtSize / 8), width: txtSize / 2, height: txtSize);
    var isInclude = false;

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
      for (var dx = x; dx < bounds.topRight.dx; dx = txtSize > 3 ? dx + 5.0 : dx + 1.0) {
        for (var dy = y; dy > bounds.topRight.dy; dy = txtSize > 3 ? dy - 5.0 : dy - 1.0) {
          if (path.contains(Offset(dx.toDouble(), dy.toDouble()))) {
            textRect = Rect.fromCenter(
              center: Offset(dx, dy),
              width: txtSize > 3 ? textPainter.width + 3 : textPainter.width + 1,
              height: txtSize > 3 ? textPainter.height + 3 : textPainter.height + 1,
            );
            for (var i = textRect.topLeft.dx; i < textRect.topRight.dx; i += 1.0) {
              if (textRect.topRight.dx - i < 1.0) {
                i = textRect.topRight.dx;
              }
              for (var j = textRect.bottomRight.dy; j > textRect.topRight.dy; j -= 1.0) {
                if (j - textRect.topRight.dy < 1.0) {
                  j = textRect.topRight.dy;
                }
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
          break;
        }
      }
      if (!isInclude) {
        txtSize -= 0.5;
        if (txtSize <= 0.1) {
          txtSize = 1;
          for (var dx = bounds.topLeft.dx + (bounds.topRight.dx / 2); dx < bounds.topRight.dx; dx += 3.0) {
            if (bounds.topRight.dx - dx < 3.0) {
              dx = bounds.topRight.dx;
            }
            for (var dy = bounds.bottomRight.dy - (bounds.topRight.dy / 2); dy > bounds.topRight.dy; dy -= 3.0) {
              if (dy - bounds.topRight.dy < 3.0) {
                dy = bounds.topRight.dy;
              }
              if (path.contains(Offset(dx.toDouble(), dy.toDouble()))) {
                textRect = Rect.fromCenter(
                  center: Offset(dx, dy),
                  width: textPainter.width,
                  height: textPainter.height,
                );
              }
            }
          }

          isInclude = true;
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
