import 'package:flutter/material.dart';

class ScaleNotifier extends ValueNotifier<double> {
  ScaleNotifier(double value) : super(value);

  set scale(double scale) {
    _scale = scale;
    notifyListeners();
  }

  double _scale = 0.0;
}
