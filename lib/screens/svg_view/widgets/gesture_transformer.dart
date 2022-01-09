import 'package:flutter/material.dart';

class GestureTransformer extends StatefulWidget {
  final Widget child;
  const GestureTransformer({required this.child, Key? key}) : super(key: key);

  @override
  _GestureTransformerState createState() => _GestureTransformerState();
}

class _GestureTransformerState extends State<GestureTransformer> with TickerProviderStateMixin {
  Offset currentScaleOffset = Offset.zero;
  double currentScale = 1;
  FilterQuality? filterQuality;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) => setState(() {
        /* debugPrint(details.scale.toString());
        if (details.scale > 3) {
          filterQuality = null;
        } else {
          filterQuality = FilterQuality.high;
        } */
        currentScale = details.scale;
      }),
      child: currentScale > 3 ? Transform(
        alignment: Alignment.center,
        transform: Matrix4.translationValues( 0,
                                  0, 0,)..scale(currentScale),
        child: widget.child,
      ) : Transform(
        filterQuality: FilterQuality.high,
        alignment: Alignment.center,
        transform: Matrix4.translationValues( 0,
                                  0, 0,)..scale(currentScale),
        child: widget.child,
      ),
    );
  }
}
