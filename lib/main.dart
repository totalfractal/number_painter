import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:number_painter/core/painter_tools.dart';
import 'package:number_painter/screens/loading_screen.dart';
import 'package:number_painter/screens/svg_view/svg_view_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      home: PainterChoice(), /* SvgViewScreen(
        id: 'mandala2-01',
      ), */
    ),
  );
}

class PainterChoice extends StatefulWidget {
  const PainterChoice({Key? key}) : super(key: key);

  @override
  State<PainterChoice> createState() => _PainterChoiceState();
}

class _PainterChoiceState extends State<PainterChoice> {
  final _list = <String>[];
  @override
  void initState() {
    super.initState();
    () async {
      await _initImages();
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: _list
          .map((e) => InkWell(
            onLongPress: () => DefaultAssetBundle.of(context).loadString(e).then((value) => PainterTools.dbProvider.deletePainter(e)),
            onTap: () => DefaultAssetBundle.of(context).loadString(e).then((value) => Navigator.of(context).push<void>(MaterialPageRoute(builder: (context) => LoadingScreen(id: e, svgString: value,)))),
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(16.0),
              child: Text(e),
            ),
          ))
          .toList(),
    ),);
  }

  Future _initImages() async {
    // >> To get paths you need these 2 lines
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    // >> To get paths you need these 2 lines
    setState(() {
      _list.addAll(manifestMap.keys.where((String key) => key.contains('assets/')).where((String key) => key.contains('.svg')));
    });
  }
}
