import 'package:flutter/material.dart';
import 'package:number_painter/screens/svg_view/widgets/radial_progress_painter.dart';

class ColorItem extends StatefulWidget {
  final VoidCallback? onTap;
  final Color color;
  final int number;
  final double currentPercent;
  final double oldPercent;
  final AnimationController percentController;
  final bool selected;
  const ColorItem({
    required this.number,
    required this.color,
    required this.percentController,
    this.currentPercent = 0,
    this.oldPercent = 0,
    Key? key,
    this.onTap,
    this.selected = false,
  })  : assert(number >= 0),
        super(key: key);

  @override
  State<ColorItem> createState() => _ColorItemState();
}

class _ColorItemState extends State<ColorItem> with SingleTickerProviderStateMixin {
  double percentage = 0;
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: widget
            .onTap 
        ,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 55,
          height: 55,
          margin: widget.selected ? const EdgeInsets.only(bottom: 20, left: 5, right: 5) : const EdgeInsets.symmetric(horizontal: 5),
          child: widget.selected
              ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(top: -20, bottom: -10, left: -20, right: -20, child: DecoratedBox(decoration: BoxDecoration( color: Colors.teal[50], shape: BoxShape.circle,),),),
                  RepaintBoundary(
                      child: CustomPaint(
                        painter: RadialProgressPainter(
                          // В зависимости от яркости цвета сделать RadialProgress светлее/темнее
                          bgColor: widget.color.computeLuminance() >= 0.4 ? _darken(widget.color, .2) : _lighten(widget.color, .2),
                          lineColor: widget.color,
                          width: 10.0,
                          oldPercent: widget.oldPercent,
                          currentPercent: widget.currentPercent,
                          animation: widget.percentController,
                        ),
                        child: Container(
                          decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              '${widget.number + 1}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )
              : Container(
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '${widget.number + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
        ),
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