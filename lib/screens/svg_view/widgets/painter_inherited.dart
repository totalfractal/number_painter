import 'package:flutter/material.dart';
import 'package:number_painter/core/db_provider.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';

class PainterInherited extends InheritedWidget {
  final DBProvider dbProvider;
  final PainterProgressModel painterProgress;
  final List<SvgShapeModel> svgShapes;
  final List<SvgShapeModel> selectedShapes;

  const PainterInherited({
    required this.dbProvider,
    required this.painterProgress,
    required this.svgShapes,
    required this.selectedShapes,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  static PainterInherited of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<PainterInherited>();
    assert(result != null, 'No PainterInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(PainterInherited oldWidget) => true;
}
