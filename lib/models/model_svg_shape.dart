import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

class ModelSvgShape {
  final String id;
  final String d;
  final HexColor fill;
  final List<ModelSvgShape> listModelSvgFile;
  final Path _path;
  bool isPainted = false;
  bool isPicked = false;
  int sortedId = -1;
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
      HexColor(svgElement.getAttribute('fill').toString()),
      svgElement.findElements('path').map<ModelSvgShape>((e) => ModelSvgShape.fromElement(e)).toList(),
    );
  }

  factory ModelSvgShape.epmty() {
    return ModelSvgShape._(
      '',
      '',
      HexColor('FF000000'),
      [],
    );
  }


  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) => transformedPath = _path.transform(matrix.storage);
}
