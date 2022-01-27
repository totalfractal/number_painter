import 'package:flutter/material.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:number_painter/core/models/svg_models/svg_line_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/core/painter_tools.dart';
import 'package:number_painter/screens/svg_view/svg_view_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String svgString;
  final String id;
  const LoadingScreen({required this.svgString, required this.id, Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final PainterProgressModel _painterProgress = PainterProgressModel.fromScratch(id: widget.id, shapes: _svgShapes.join(' '), isCompleted: false);
  final List<SvgShapeModel> _svgShapes = [];
  final List<SvgLineModel> _svgLines = [];
  final Map<Color, List<SvgShapeModel>> _sortedShapes = {};
  FittedSizes _fittedSvgSize = const FittedSizes(Size.zero, Size.zero);
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), _initPainter).then(
      (_) => Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => SvgViewScreen(
            painterProgressModel: _painterProgress,
            svgShapes: _svgShapes,
            svgLines: _svgLines,
            sortedShapes: _sortedShapes,
            fittedSvgSize: _fittedSvgSize,
          ),
        ),
      ),
    );
    //_initPainter();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Загрузка',
          style: TextStyle(fontSize: 17, color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _initPainter() async {
    _fittedSvgSize = PainterTools.getFittedSize(context, widget.svgString);
    PainterTools.setLinesAndShapes(context, widget.svgString, _svgShapes, _svgLines, _fittedSvgSize);
    await PainterTools.getDbPainter(widget.id, _svgShapes, _painterProgress).then((value) {
      //compute(PainterTools.setSortedShapes, _svgShapes).then((value) => null);
      _sortedShapes.addAll(PainterTools.setSortedShapes(_svgShapes));
      
    });
  }
}
