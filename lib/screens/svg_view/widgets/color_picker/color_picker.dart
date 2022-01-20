import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:number_painter/core/models/color_list_model.dart';
import 'package:number_painter/core/models/svg_models/svg_shape_model.dart';
import 'package:number_painter/screens/svg_view/widgets/color_picker/color_item.dart';
import 'package:number_painter/screens/svg_view/widgets/radial_painter.dart';
import 'package:number_painter/screens/svg_view/widgets/radial_progress_painter.dart';

class ColorPicker extends StatefulWidget {
  final Map<Color, List<SvgShapeModel>> sortedShapes;
  final ValueChanged<Color> onColorSelect;
  final AnimationController percentController;

  const ColorPicker({required this.sortedShapes, required this.onColorSelect, required this.percentController, Key? key}) : super(key: key);

  @override
  ColorPickerState createState() => ColorPickerState();
}

class ColorPickerState extends State<ColorPicker> with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late final _colorList = _calcPaintedColors();
  late final ColorListModel<Color> _animatedList = ColorListModel<Color>(
    listKey: _listKey,
    initialItems: _colorList,
    removedItemBuilder: _buildRemovedItem,
  );
  late final Map<Color, List<SvgShapeModel>> _sortedShapes = Map.from(widget.sortedShapes);
  Color selectedColor = Colors.transparent;
  double currentPercent = 0;
  double oldPercent = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Color> _calcPaintedColors() {
    final colorsList = <Color>[];
    for (final pair in _sortedShapes.entries) {
      var paintedPair = false;
      for (final shape in pair.value) {
        if (shape.isPainted) {
          paintedPair = true;
          break;
        }
      }
      if (!paintedPair) {
        colorsList.add(pair.key);
      }
    }
    return colorsList;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        initialItemCount: _animatedList.length,
        itemBuilder: _buildItem,
      ),
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    final currentColor = _animatedList[index];
    final colorIndex = _sortedShapes.keys.toList().indexOf(currentColor);
    //final currentShapes = _sortedShapes.values.elementAt(colorIndex);
    //final currentPercent = currentShapes.where((shape) => shape.isPainted).length / currentShapes.length;
    //final oldPercent = currentPercent != 0 ? (currentShapes.where((shape) => shape.isPainted).length - 1) / currentShapes.length : .0;

    return SizeTransition(
      key: UniqueKey(),
      sizeFactor: animation,
      child: ColorItem(
        percentController: widget.percentController,
        number: colorIndex,
        selected: selectedColor == _sortedShapes.keys.elementAt(colorIndex),
        onTap: () {
          setState(() {
            selectedColor = _sortedShapes.keys.elementAt(colorIndex);
            widget.onColorSelect(selectedColor);
          });
        },
        color: currentColor,
        currentPercent: currentPercent,
        oldPercent: oldPercent,
      ),
    );
  }

  // Used to build an item after it has been removed from the list. This
  // method is needed because a removed item remains visible until its
  // animation has completed (even though it's gone as far this ListModel is
  // concerned). The widget will be used by the
  // [AnimatedListState.removeItem] method's
  // [AnimatedListRemovedItemBuilder] parameter.
  Widget _buildRemovedItem(
    Color color,
    BuildContext context,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset(0, 0),
      ).animate(animation),
      child: ColorItem(
        number: _sortedShapes.keys.toList().indexOf(color), color: color, percentController: widget.percentController,
        // No gesture detector here: we don't want removed items to be interactive.
      ),
    );
  }

  // Remove the selected item from the list model.
  void remove(Color color) {
    var index = _animatedList.indexOf(color);
    _animatedList.removeAt(index);
    setState(() {
      selectedColor = Colors.transparent;
    });
  }

  void setPercent(double oldPerc, double perc) {
    setState(() {
      oldPercent = oldPerc;
      currentPercent = perc;
    });
  }
}
