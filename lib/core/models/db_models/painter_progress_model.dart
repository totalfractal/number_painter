import 'package:number_painter/core/models/svg_models/model_svg_shape.dart';

class PainterProgressModel {
  static const table = 'Painters';

  final String id;
  final List<ModelSvgShape> shapes;
  bool isCompleted; // 0 / 1

  PainterProgressModel._({
    required this.id,
    required this.shapes,
    required this.isCompleted,
  });

  factory PainterProgressModel.fromMap(Map<String, dynamic> map) {
    final shapes = <ModelSvgShape>[];
    return PainterProgressModel._(id: map['id'] as String, shapes: shapes, isCompleted: map['isCompleted'] == 1);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{'id': id, 'shapes': shapes.toString(), 'isCompleted': isCompleted};

  
}
