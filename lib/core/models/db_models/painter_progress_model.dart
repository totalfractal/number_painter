import 'dart:convert';

class PainterProgressModel {
  static const table = 'Painters';

  final String id;
  String shapes;
  bool isCompleted; // 0 / 1
  PainterProgressModel._({
    required this.id,
    required this.shapes,
    required this.isCompleted,
  });

  factory PainterProgressModel.fromJsonString(String str) {
    final jsonData = json.decode(str) as Map<String, dynamic>;
    return PainterProgressModel.fromMap(jsonData);
  }

  factory PainterProgressModel.fromScratch({
    required String id,
    required String shapes,
    required bool isCompleted,
  }) {
    return PainterProgressModel._(id: id, shapes: shapes, isCompleted: isCompleted);
  }

  factory PainterProgressModel.fromMap(Map<String, dynamic> map) {
    
    return PainterProgressModel._(id: map['id'] as String, shapes: map['shapes'] as String , isCompleted: map['isCompleted'] == 1);
  }

  String toJsonString(PainterProgressModel data) {
    final dyn = data.toMap();
    return json.encode(dyn);
  }

  Map<String, dynamic> toMap() => <String, dynamic>{'id': id, 'shapes': shapes.toString(), 'isCompleted': isCompleted ? 1 : 0};
}
