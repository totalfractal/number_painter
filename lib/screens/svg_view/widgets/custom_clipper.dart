import 'package:flutter/material.dart';
import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';

class MyCustomClipper extends CustomClipper<Path> {
  final ModelSvgShape selectedPath;

  MyCustomClipper({required this.selectedPath});
  @override
  Path getClip(Size size) {
    return selectedPath.transformedPath!;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
