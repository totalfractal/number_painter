import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/models/model_svg_shape.dart';
import 'package:number_painter/widgets/circular_progress_indicator.dart';

class ColorPicker extends StatefulWidget {
  final Map<HexColor, List<ModelSvgShape>> sortedShapes;
  final ValueChanged<int> setSelectedColor;

  const ColorPicker({required this.sortedShapes, required this.setSelectedColor, Key? key}) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int selectedColor = -1;
  //double percent = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ColoredBox(
        color: Colors.white,
        child: ListView.separated(
          separatorBuilder: (_, __) => const SizedBox(
            width: 10,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: widget.sortedShapes.length,
          itemBuilder: (context, index) {
            final currentColor = widget.sortedShapes.keys.elementAt(index);
            final currentShapes = widget.sortedShapes.values.elementAt(index);
            final percent = currentShapes.where((shape) => shape.isPainted).length / currentShapes.length;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = index;
                  widget.setSelectedColor(selectedColor);
                });
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  foregroundPainter: RadialPainter(
                    bgColor: currentColor.computeLuminance() >= 0.4 ? _darken(currentColor, .2) : _lighten(currentColor, .2),
                    lineColor: currentColor,
                    percent: percent,
                    width: 5.0,
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
                ),
              ),
            );
          },
        ),
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
