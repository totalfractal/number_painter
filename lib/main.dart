import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:number_painter/screens/svg_view/svg_view_screen.dart';




void main() {
  runApp(const MaterialApp(
    home: SvgViewScreen(id: 'landscape1',),
  ));
}
