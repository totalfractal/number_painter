import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/models/model_svg_shape.dart';
import 'package:number_painter/radial_painter.dart';
import 'package:number_painter/radial_progress_painter.dart';

class ColorPicker extends StatefulWidget {
  final Map<Color, List<ModelSvgShape>> sortedShapes;
  final ValueChanged<Color> setSelectedColor;
  final AnimationController percentController;

  const ColorPicker({required this.sortedShapes, required this.setSelectedColor, required this.percentController, Key? key}) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> with SingleTickerProviderStateMixin {
  Color selectedColor = Colors.transparent;
  //double oldPercent = 0.0;
  //List<ModelSvgShape> currentShapes = [];
  //double currentPercent = 0.0;

  @override
  void initState() {
    super.initState();
    widget.percentController..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(
          width: 16,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: widget.sortedShapes.length,
        itemBuilder: (context, index) {
          final currentColor = widget.sortedShapes.keys.elementAt(index);
          final currentShapes = widget.sortedShapes.values.elementAt(index);
          final currentPercent = currentShapes.where((shape) => shape.isPainted).length / currentShapes.length;
          final oldPercent = currentPercent != 0 ? (currentShapes.where((shape) => shape.isPainted).length - 1) / currentShapes.length : .0;
          //print(currentPercent);
         // print(oldPercent);

          //oldPercent = (currentShapes.where((shape) => shape.isPainted).length - 1) / currentShapes.length;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = widget.sortedShapes.keys.elementAt(index);
                widget.setSelectedColor(selectedColor);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 55,
              height: 55,
              margin: selectedColor == widget.sortedShapes.keys.elementAt(index) ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
              child: selectedColor == widget.sortedShapes.keys.elementAt(index)
                  ? RepaintBoundary(
                    child: CustomPaint(
                        painter: RadialProgressPainter(
                          bgColor: currentColor.computeLuminance() >= 0.4 ? _darken(currentColor, .2) : _lighten(currentColor, .2),
                          lineColor: currentColor,
                          width: 5.0,
                          oldPercent: oldPercent,
                          currentPercent: currentPercent,
                          animation: widget.percentController,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(color: widget.sortedShapes.keys.elementAt(index), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        foregroundPainter: RadialPainter(
                          lineColor: currentColor,
                          width: 5.0, currentPercent: currentPercent,),
                      ),
                  )
                  : Padding(
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        decoration: BoxDecoration(color: widget.sortedShapes.keys.elementAt(index), shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color _lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
