import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
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
import 'package:number_painter/screens/svg_view/widgets/reward_button.dart';
import 'package:number_painter/screens/svg_view/widgets/shape_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/zoom_out_button.dart';

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

  final _transformationController = TransformationController();

  final _rewards = Rewards();

  final _zoomKey = GlobalKey<ZoomOutButtonState>();

  bool isInit = false;

  FToast? _currentToast;

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
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _transformationController.value =
          Matrix4Transform().scale(1.15, origin: Offset(widget.fittedSvgSize.destination.width/2,widget.fittedSvgSize.destination.height/2)).matrix4;
    });

    _transformationController.addListener(() {
      _scaleNotifier.value = _transformationController.value.getMaxScaleOnAxis();
    });
    _rewards.createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    debugPrint('build');
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body:
            // Этот виджет нужен для переброса данных в другие виджеты
            //c помощью PainterInherited.of(context)
            PainterInherited(
          painterProgress: widget.painterProgressModel,
          svgShapes: widget.svgShapes,
          selectedShapes: _selectedShapes,
          onComplete: () => setState(
            () {
              _zoomKey.currentState!.animateResetInitialize();
              widget.painterProgressModel.isCompleted = true;
              PainterTools.dbProvider.updatePainter(widget.painterProgressModel);
              Toasts.showCompleteToast(context, 10);
            },
          ),
          rewardCallback: () => setState(() {}),
          child: Stack(
            children: [
              OrientationBuilder(
                builder: (context, orientation) {
                  return InteractiveViewer(
                    transformationController: _transformationController,
                    onInteractionUpdate: (details) {
                      _scaleNotifier.value = _transformationController.value.getMaxScaleOnAxis();
                    },
                    minScale: 0.1,
                    maxScale: 100.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: _size.width,
                          height: _size.height,
                          child: const CheckersPaint(),
                        ),
                        SizedBox(
                          width: _size.width,
                          height: _size.height,
                          child: ManyCirclesPaint(
                            notifier: _offsetNotifier,
                            selectedColoredShapes: _selectedColoringShapes,
                            percentController: _percentController,
                            colorListKey: _colorListKey,
                            onEndCircle: () => setState(() {}),
                          ),
                        ),
                        SizedBox(
                          width: _size.width,
                          height: _size.height,
                          child: FadePaint(fadeController: _fadeController, selectedSvgShapes: _selectedShapes),
                        ),
                        SizedBox(
                          width: _size.width,
                          height: _size.height,
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
                                  lines: widget.svgLines,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IgnorePointer(
                          child: SizedBox(
                            width: _size.width,
                            height: _size.height,
                            child: LinePaint(svgLines: widget.svgLines),
                          ),
                        ),
                        IgnorePointer(
                          child: SizedBox(
                            width: _size.width,
                            height: _size.height,
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
                  );
                },
              ),
              Visibility(
                visible: !widget.painterProgressModel.isCompleted,
                child: Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 10,
                  child: HelpButton(
                    transformationController: _transformationController,
                    selectedShapes: _selectedShapes,
                    rewards: _rewards,
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
              Visibility(
                visible: !widget.painterProgressModel.isCompleted,
                child: RewardButton(
                  rewards: _rewards,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: !widget.painterProgressModel.isCompleted,
                  child: ColorPicker(
                    key: _colorListKey,
                    percentController: _percentController,
                    sortedShapes: widget.sortedShapes,
                    onColorSelect: _callBackIndexColorOfColorPicker,
                    rewards: _rewards,
                  ),
                ),
              ),

              Positioned(
                bottom: 200,
                right: 10,
                child: ZoomOutButton(key: _zoomKey, transformController: _transformationController),
              ),
            ],
          ),
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
            break;
          }
        }
      }
    } else {
      _showPickToast(context);
    }
  }

  void _showPickToast(BuildContext context) {
    if (_currentToast == null && !widget.painterProgressModel.isCompleted) {
      _currentToast = Toasts.showPickColorToast(context, 10);
      Future<void>.delayed(const Duration(seconds: 5), () {
        _currentToast?.removeCustomToast();
        _currentToast = null;
      });
    }
  }

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
}
