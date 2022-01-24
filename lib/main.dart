import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:number_painter/core/painter_tools.dart';
import 'package:number_painter/screens/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(
    const MaterialApp(
      home: PainterChoice(),
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

    final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;
    // >> To get paths you need these 2 lines
    setState(() {
      _list.addAll(manifestMap.keys.where((key) => key.contains('assets/')).where((key) => key.contains('.svg')));
    });
  }
}
