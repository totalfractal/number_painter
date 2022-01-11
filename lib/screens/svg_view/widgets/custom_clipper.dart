import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';

class MyCustomClipper extends CustomClipper<Path> {
  final SvgShapeModel selectedPath;

  MyCustomClipper({required this.selectedPath});
  @override
  Path getClip(Size size) {
    return selectedPath.transformedPath!;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
