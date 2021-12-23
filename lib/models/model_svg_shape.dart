import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class ModelSvgShape {
  final String id;
  final String d;
  final String fill;
  final List<ModelSvgShape> listModelSvgFile;
  final Path _path;
  bool isPainted = false;
  Path? transformedPath;
  ModelSvgShape._(
    this.id,
    this.d,
    this.fill,
    this.listModelSvgFile,
  ) : _path = parseSvgPathData(d);

  factory ModelSvgShape.fromElement(XmlElement svgElement) {
    return ModelSvgShape._(
      svgElement.getAttribute('id').toString(),
      svgElement.getAttribute('d').toString(),
      svgElement.getAttribute('fill').toString(),
      svgElement.findElements('path').map<ModelSvgShape>((e) => ModelSvgShape.fromElement(e)).toList(),
    );
  }

  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) => transformedPath = _path.transform(matrix.storage);
}
