import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/screens/svg_view/widgets/radial_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/radial_progress_painter.dart';

class ColorPicker extends StatefulWidget {
  final Map<Color, List<SvgShapeModel>> sortedShapes;
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
    widget.percentController.addListener(_percentControllerListener);
  }

  @override
  void dispose() {
    widget.percentController.removeListener(_percentControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) {
          final currentColor = widget.sortedShapes.keys.elementAt(index);
          final currentShapes = widget.sortedShapes.values.elementAt(index);
          final currentPercent = currentShapes.where((shape) => shape.isPainted).length / currentShapes.length;
          return SizedBox(
            width: currentPercent < 1 ? 16 : 0,
          );
        },
        itemCount: widget.sortedShapes.length,
        itemBuilder: (context, index) {
          final currentColor = widget.sortedShapes.keys.elementAt(index);
          final currentShapes = widget.sortedShapes.values.elementAt(index);
          final currentPercent = currentShapes.where((shape) => shape.isPainted).length / currentShapes.length;
          final oldPercent = currentPercent != 0 ? (currentShapes.where((shape) => shape.isPainted).length - 1) / currentShapes.length : .0;

          return AnimatedSwitcher(
            duration: const Duration(microseconds: 300),
            child: currentPercent < 1
                ? GestureDetector(
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
                                  // В зависимости от яркости цвета сделать RadialProgress светлее/темнее
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
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                foregroundPainter: RadialPainter(
                                  lineColor: currentColor,
                                  width: 5.0,
                                  currentPercent: currentPercent,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(color: widget.sortedShapes.keys.elementAt(index), shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Сделать цвет RadialProgress темнее
  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  /// Сделать цвет RadialProgress светлее
  Color _lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  void _percentControllerListener() => setState(() {});
}
