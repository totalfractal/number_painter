import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:number_painter/core/models/coloring_shape.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:number_painter/core/models/svg_models/svg_line_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/core/painter_tools.dart';
import 'package:number_painter/core/rewards.dart';
import 'package:number_painter/core/toast.dart';
import 'package:number_painter/screens/svg_view/widgets/checkers_paint/checkers_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/circle_paint/circle_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/color_picker/color_picker.dart';
import 'package:number_painter/screens/svg_view/widgets/fade_paint/fade_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/help_button.dart';
import 'package:number_painter/screens/svg_view/widgets/line_paint/line_paint.dart';
import 'package:number_painter/screens/svg_view/widgets/number_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/painter_inherited.dart';
import 'package:number_painter/screens/svg_view/widgets/shape_painter.dart';

class SvgViewScreen extends StatefulWidget {
  final PainterProgressModel painterProgressModel;
  final List<SvgShapeModel> svgShapes;
  final List<SvgLineModel> svgLines;
  final Map<Color, List<SvgShapeModel>> sortedShapes;
  final FittedSizes fittedSvgSize;
  const SvgViewScreen({
    required this.painterProgressModel,
    required this.svgShapes,
    required this.svgLines,
    required this.sortedShapes,
    required this.fittedSvgSize,
    Key? key,
  }) : super(key: key);

  @override
  _SvgViewScreenState createState() => _SvgViewScreenState();
}

class _SvgViewScreenState extends State<SvgViewScreen> with TickerProviderStateMixin {
  final _offsetNotifier = ValueNotifier(Offset.zero);
  final _scaleNotifier = ValueNotifier(1.0);

  final List<ColoringShape> _selectedColoringShapes = [];

  final GlobalKey<ColorPickerState> _colorListKey = GlobalKey<ColorPickerState>();

  late final _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  late final _percentController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

  late final AnimationController _controllerReset = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  final _transformationController = TransformationController();

  late final _rewards = Rewards()..createRewardedAd();

  bool isInit = false;

  FToast? _currentToast;

  Animation<Matrix4>? _animationReset;

  List<SvgShapeModel> _selectedShapes = [];
  SvgShapeModel _selectedShape = SvgShapeModel.epmty();

  Color? _selectedColor;

  @override
  void dispose() {
    _fadeController.dispose();
    _offsetNotifier.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      _scaleNotifier.value = _transformationController.value.getMaxScaleOnAxis();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    debugPrint('build');
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          // Этот виджет нужен для переброса данных в другие виджеты
          //c помощью PainterInherited.of(context)
          PainterInherited(
        painterProgress: widget.painterProgressModel,
        svgShapes: widget.svgShapes,
        selectedShapes: _selectedShapes,
        onComplete: () => setState(() {
          _animateResetInitialize();
          widget.painterProgressModel.isCompleted = true;
          PainterTools.dbProvider.updatePainter(widget.painterProgressModel);
          Toasts.showCompleteToast(context, 10);
        }),
        child: Column(
          children: <Widget>[
            const Spacer(),
            Stack(
              children: [
                InteractiveViewer(
                  transformationController: _transformationController,
                  onInteractionUpdate: (details) {
                    //debugPrint(details.scale.toString());
                    _scaleNotifier.value = _transformationController.value.getMaxScaleOnAxis();
                  },
                  onInteractionStart: _onInteractionStart,
                  minScale: 0.1,
                  maxScale: 100.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: widget.fittedSvgSize.destination.width,
                        height: widget.fittedSvgSize.destination.height,
                        child: const CheckersPaint(),
                      ),
                      SizedBox(
                        width: _size.width,
                        height: _size.height * 0.85,
                        child: ManyCirclesPaint(
                          notifier: _offsetNotifier,
                          selectedColoredShapes: _selectedColoringShapes,
                          percentController: _percentController,
                          colorListKey: _colorListKey,
                        ),
                      ),
                      SizedBox(
                        width: _size.width,
                        height: _size.height * 0.85,
                        child: FadePaint(fadeController: _fadeController, selectedSvgShapes: _selectedShapes),
                      ),
                      SizedBox(
                        width: _size.width,
                        height: _size.height * 0.85,
                        child: Listener(
                          onPointerUp: (e) {
                            _onTapUp(e, context);
                          },
                          child: RepaintBoundary(
                            child: CustomPaint(
                              isComplex: true,
                              painter: ShapePainter(
                                notifier: _offsetNotifier,
                                shapes: widget.svgShapes,
                                selectedShapes: _selectedShapes,
                                lines: widget.svgLines,
                                sortedShapes: widget.sortedShapes,
                                selectedColor: _selectedColor,
                                isInit: isInit,
                                center: Offset(
                                  _size.width / 2,
                                  _size.height * 0.85 / 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: SizedBox(
                          width: _size.width,
                          height: _size.height * 0.85,
                          child: LinePaint(svgLines: widget.svgLines),
                        ),
                      ),
                      IgnorePointer(
                        child: SizedBox(
                          width: _size.width,
                          height: _size.height * 0.85,
                          //С помощью этого виджета слушаем изменения при зуме
                          child: ValueListenableBuilder(
                            valueListenable: _scaleNotifier,
                            builder: (context, scale, child) {
                              return RepaintBoundary(
                                child: CustomPaint(
                                  painter: NumberPainter(shapes: widget.svgShapes, scale: scale as double),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: _animateResetInitialize,
                    child: const Icon(Icons.zoom_out_map_rounded),
                  ),
                ),
                Visibility(
                  visible: !widget.painterProgressModel.isCompleted,
                  child: Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 10,
                    child: HelpButton(
                      transformationController: _transformationController,
                      selectedShapes: _selectedShapes,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.green,
                    ),
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 10,
                  left: 10,
                  child: IconButton(
                    onPressed: _rewards.showRewardedAd,
                    icon: const Icon(
                      Icons.monetization_on_outlined,
                      size: 50,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(
              height: 1,
              color: Colors.black,
            ),
            Visibility(
              visible: !widget.painterProgressModel.isCompleted,
              child: Container(
                alignment: Alignment.center,
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: ColorPicker(
                  key: _colorListKey,
                  percentController: _percentController,
                  sortedShapes: widget.sortedShapes,
                  onColorSelect: _callBackIndexColorOfColorPicker,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapUp(PointerUpEvent e, BuildContext context) {
    if (_selectedColor != null) {
      for (final shape in _selectedShapes) {
        if (shape.transformedPath!.contains(e.localPosition)) {
          if (_selectedShape != shape && !shape.isPainted) {
            _offsetNotifier.value = e.localPosition;
            setState(() {
              _selectedShape = shape;
              _selectedColoringShapes.add(ColoringShape(cicrclePosition: e.localPosition, shape: shape));
            });
          }
        }
      }
    } else {
      _showPickToast(context);
    }
  }

  void _showPickToast(BuildContext context) {
    if (_currentToast == null) {
      _currentToast = Toasts.showPickColorToast(context, 10);
      Future<void>.delayed(const Duration(seconds: 5), () {
        _currentToast?.removeCustomToast();
        _currentToast = null;
      });
    }
  }

/*   void _initPainter() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      fittedSvgSize = PainterTools.getFittedSize(context, widget.svgString);
      PainterTools.setLinesAndShapes(context, widget.svgString, _svgShapes, _svgLines, fittedSvgSize);
      _painterProgress = PainterProgressModel.fromScratch(id: widget.id, shapes: _svgShapes.join(' '), isCompleted: false);
      PainterTools.getDbPainter(widget.id, _svgShapes, _painterProgress).then((value) {
        //compute(PainterTools.setSortedShapes, _svgShapes).then((value) => null);
        _sortedShapes.addAll(PainterTools.setSortedShapes(_svgShapes));
        _isInit = true;
        setState(() {});
      });
    });
  } */

  void _callBackIndexColorOfColorPicker(Color selectedColor) {
    if (_selectedColor != selectedColor) {
      _selectedColoringShapes.clear();
      _selectedColor = selectedColor;
      _selectedShapes = widget.sortedShapes[selectedColor]!;
      for (final shape in widget.svgShapes) {
        if (shape.fill == _selectedColor) {
          shape.isPicked = true;
        } else {
          shape.isPicked = false;
        }
      }
      setState(() {});
      _fadeController.forward(from: 0.0);
    }
    debugPrint('_callBackIndexColorOfColorPicker: $_selectedColor');
  }

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

// Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }
}
