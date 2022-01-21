import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class SvgLineModel {
  final String id;
  final String d;
  final String stroke;
  final double strokeWidth;
  final double? strokeMiterlimit;
  final String? strokeLinecap;
  final Paint paint;
  //final List<ModelSvgLine> listModelSvgFile;
  final Path _path;
  Path? transformedPath;
  SvgLineModel._(
    this.id,
    this.d,
    this.stroke,
    this.strokeWidth,
    this.strokeMiterlimit,
    this.strokeLinecap,
    this.paint,
    //this.listModelSvgFile,
  ) : _path = parseSvgPathData(d);

  factory SvgLineModel.fromElement(XmlElement svgElement) {
    final paint = Paint()
      ..color = HexColor('#1A171B')
      ..strokeWidth = svgElement.getAttribute('stroke-width') != null
          ? double.tryParse(svgElement.getAttribute('stroke-width')!) != null
              ?  double.parse(svgElement.getAttribute('stroke-width')!)
              : 0
          : 0
      ..style = PaintingStyle.stroke
      ..strokeMiterLimit =
          svgElement.getAttribute('stroke-miterlimit') != null ? double.tryParse(svgElement.getAttribute('stroke-miterlimit')!) ?? 0 : 0
      ..strokeCap = StrokeCap.round;

    return SvgLineModel._(
      svgElement.getAttribute('id').toString(),
      svgElement.getAttribute('d').toString(),
      svgElement.getAttribute('stroke').toString(),
      svgElement.getAttribute('stroke-width') != null ? double.tryParse(svgElement.getAttribute('stroke-width')!) ?? 0 : 0,
      svgElement.getAttribute('stroke-miterlimit') != null ? double.tryParse(svgElement.getAttribute('stroke-miterlimit')!) ?? 0 : 0,
      svgElement.getAttribute('stroke-linecap'),
      paint,
      //svgElement.findElements('path').map<ModelSvgLine>((e) => ModelSvgLine.fromElement(e)).toList(),
    );
  }

  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) => transformedPath = _path.transform(matrix.storage);
}


