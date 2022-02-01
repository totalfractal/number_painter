import 'package:flutter/material.dart';

class ZoomOutButton extends StatefulWidget {
  final TransformationController transformController;
  const ZoomOutButton({required this.transformController, Key? key}) : super(key: key);

  @override
  ZoomOutButtonState createState() => ZoomOutButtonState();
}

class ZoomOutButtonState extends State<ZoomOutButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controllerReset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

   Animation<Matrix4>? _animationReset;

  @override
  void dispose() {
    _controllerReset.dispose();
    super.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: animateResetInitialize,
      icon: const Icon(
        Icons.zoom_out_map_outlined,
        size: 40,
        color: Colors.green,
      ),
    );
  }

  void animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: widget.transformController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  void _onAnimateReset() {
    widget.transformController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }
}
