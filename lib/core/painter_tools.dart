import 'package:flutter/material.dart';
import 'package:number_painter/core/db_provider.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:number_painter/core/models/svg_models/svg_line_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:xml/xml.dart';

class PainterTools {
  static final dbProvider = DBProvider();

  ///Сортировать список с областями по цветам
  static Map<Color, List<SvgShapeModel>> setSortedShapes(List<SvgShapeModel> shapes) {
    debugPrint(DateTime.now().toString());
    final sortedShapes = <Color, List<SvgShapeModel>>{};
    for (final shape in shapes) {
      if (sortedShapes.containsKey(shape.fill)) {
        sortedShapes[shape.fill]!.add(shape);
        shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
      } else {
        sortedShapes[shape.fill] = [shape];
        shape.setNumberProperties(sortedShapes.keys.toList().indexOf(shape.fill));
      }
    }
    debugPrint(DateTime.now().toString());
    return sortedShapes;
  }

  static FittedSizes getFittedSize(BuildContext context, String svgString) {
    final svgAttributes = XmlDocument.parse(svgString).findElements('svg').first.attributes;
    //debugPrint(svgAttributes.toString());

    final svgSize = Size(
      double.parse(
        svgAttributes.firstWhere((attribute) => attribute.name.toString() == 'width').value,
      ),
      double.parse(
        svgAttributes.firstWhere((attribute) => attribute.name.toString() == 'height').value,
      ),
    );

    final canvasSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * 0.85,
    );
    debugPrint(canvasSize.toString());
    return applyBoxFit(BoxFit.contain, svgSize, canvasSize);
    //fittedSvgSize = fs.destination;
  }

  ///Задать линии и области
  static void setLinesAndShapes(BuildContext context, String svgString, List<SvgShapeModel> shapes, List<SvgLineModel> lines, FittedSizes fs) {
    //final fs = getFittedSize(context, svgString);
    final stringSvgPathShapes = List<XmlElement>.from(XmlDocument.parse(svgString).findAllElements('path'));
    final canvasSize = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * 0.85,
    );
    final r = Alignment.center.inscribe(fs.destination, Offset.zero & canvasSize);
    final matrix = Matrix4.translationValues(r.left, r.top, 0)..scale(fs.destination.width / fs.source.width);
    for (final itemPath in stringSvgPathShapes) {
      if (itemPath.toString().contains('fill')) {
        final shape = SvgShapeModel.fromElement(itemPath)..transform(matrix);
        shapes.add(shape);
      }
      if (itemPath.toString().contains('stroke')) {
        lines.add(SvgLineModel.fromElement(itemPath)..transform(matrix));
      }
    }
  }

  ///Получить из БД прогресс, если таковой имеется
  static Future<void> getDbPainter(String id, List<SvgShapeModel> shapes, PainterProgressModel painterProgress) {
    return PainterTools.dbProvider.getPainter(id).then((painter) async {
      //Если прогресс существует, то записываем его в shapes
      if (painter != null) {
        debugPrint(painter.id);
        final dbShapesStringList = painter.shapes.split(' ');
        final shapesList = dbShapesStringList.map((e) => e.split(',')[1]).toList();
        for (var i = 0; i < shapes.length; i++) {
          shapes[i].isPainted = shapesList[i] == 'true';
        }
        //Также отмечаем завершенность
        painterProgress.isCompleted = painter.isCompleted;
        //Если прогресса не существует, то добавляем новый
      } else {
        await PainterTools.dbProvider.addNewPainter(painterProgress);
      }
    });
  }
}
