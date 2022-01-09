import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:number_painter/screens/svg_view/svg_view_screen.dart';

/*dependencies:
hexcolor: ^2.0.5
xml: ^5.1.0
path_drawing: ^0.5.1*/

// ignore: leading_newlines_in_multiline_strings


void main() {
  runApp(const MaterialApp(
    home: SvgViewScreen(),
  ));
}
