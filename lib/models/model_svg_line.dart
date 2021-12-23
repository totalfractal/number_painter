import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class ModelSvgLine {
  final String id;
  final String d;
  final String stroke;
  final double strokeWidth;
  final double? strokeMiterlimit;
  final String? strokeLinecap;
  final List<ModelSvgLine> listModelSvgFile;
  final Path _path;
  Path? transformedPath;
  ModelSvgLine._(
    this.id,
    this.d,
    this.stroke,
    this.strokeWidth,
    this.strokeMiterlimit,
    this.strokeLinecap,
    this.listModelSvgFile,
  ) : _path = parseSvgPathData(d);

  factory ModelSvgLine.fromElement(XmlElement svgElement) {
    return ModelSvgLine._(
      svgElement.getAttribute('id').toString(),
      svgElement.getAttribute('d').toString(),
      svgElement.getAttribute('stroke').toString(),
      svgElement.getAttribute('stroke-width') != null ? double.tryParse(svgElement.getAttribute('stroke-width')!) ?? 0 : 0,
      svgElement.getAttribute('stroke-miterlimit') != null ? double.tryParse(svgElement.getAttribute('stroke-miterlimit')!) ?? 0 : 0,
      svgElement.getAttribute('stroke-linecap'),
      svgElement.findElements('path').map<ModelSvgLine>((e) => ModelSvgLine.fromElement(e)).toList(),
    );
  }

  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) => transformedPath = _path.transform(matrix.storage);
}