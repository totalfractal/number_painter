import 'package:flutter/material.dart';
import 'dart:math' as math;

class FollowerNotchedShape extends CircularNotchedRectangle {
  int _inverterMultiplier = 0;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (!host.overlaps(guest!)) return Path()..addRect(host);

    final double notchRadius = guest.width / 2.0;

    const double s1 = 15.0;
    const double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final p = <Offset>[]..length=6;

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] =
        cmp * p2yA > cmp * p2yB ? Offset(p2xA, _inverterMultiplier * p2yA) : Offset(p2xB, _inverterMultiplier * p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) p[i] += guest.center;

    final Path path = Path()
      ..moveTo(host.left, -host.top)
      ..lineTo(p[0].dx, -p[0].dy)
      ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy);
    if (guest.height == guest.width) {
      // circle
      path.arcToPoint(
        p[3],
        radius: Radius.circular(notchRadius),
        clockwise: _inverterMultiplier == 1 ? false : true,
      );
    } else {
      // stadium
      path
        ..arcToPoint(
          (_inverterMultiplier == 1 ? guest.bottomLeft : guest.topLeft) + Offset(guest.height / 2, 0), // here
          radius: Radius.circular(guest.height / 2),
          clockwise: _inverterMultiplier == 1 ? false : true,
        )
        ..lineTo(guest.right - guest.height / 2, (_inverterMultiplier == 1 ? guest.bottom : guest.top)) // here
        ..arcToPoint(
          p[3],
          radius: Radius.circular(guest.height / 2),
          clockwise: _inverterMultiplier == 1 ? false : true,
        );
    }
    path
      ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
    return path;
  }

  // ignore: member-ordering-extended
  FollowerNotchedShape({bool inverted = false}) {
    if (inverted) {
      _inverterMultiplier = -1;
    } else
      _inverterMultiplier = 1;
  }
}

class NotchedBottomBarItem {
  NotchedBottomBarItem({required this.iconData, required this.text});

  IconData iconData;
  String text;
}

class NotchedBottomBar extends StatefulWidget {
  NotchedBottomBar({Key? key, 
    required this.items,
    required this.centerItemText,
    this.height: 60.0,
    this.iconSize: 24.0,
    required this.backgroundColor,
    required this.color,
    required this.selectedColor,
    required this.notchedShape,
    required this.onTabSelected,
  }) : super(key: key) {
    assert(this.items.length == 2 || this.items.length == 4);
  }

  final List<NotchedBottomBarItem> items;
  final String centerItemText;
  double height;
  final double iconSize;
  final Color backgroundColor;
  final Color color;
  final Color selectedColor;
  final NotchedShape notchedShape;
  final ValueChanged<int> onTabSelected;

  @override
  State<StatefulWidget> createState() => NotchedBottomBarState();
}

class NotchedBottomBarState extends State<NotchedBottomBar> {
  int _selectedIndex = 0;

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabItem(
        item: widget.items[index],
        index: index,
        onPressed: _updateIndex,
      );
    });
    items.insert(items.length >> 1, _buildMiddleTabItem());

    return BottomAppBar(
      shape: widget.notchedShape,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
      color: widget.backgroundColor,
    );
  }

  Widget _buildMiddleTabItem() {
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: widget.iconSize),
            Text(
              widget.centerItemText ,
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required NotchedBottomBarItem item,
    required int index,
    required ValueChanged<int> onPressed,
  }) {
    Color color = _selectedIndex == index ? widget.selectedColor : widget.color;
    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              onPressed(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8),
                ),
                Icon(item.iconData, color: color, size: widget.iconSize),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                ),
                Text(
                  item.text,
                  style: TextStyle(color: color),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}