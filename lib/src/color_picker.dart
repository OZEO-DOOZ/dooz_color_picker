import 'dart:math';

import 'package:flutter/material.dart';

/// A listener which receives an color in int representation. as used
/// by [CircleColorPicker.colorListener].
typedef ColorListener = void Function(Color value);

/// A circle palette color picker.
class CircleColorPicker extends StatefulWidget {
  // radius of the color palette, note that radius * 2 is not the final
  // width of this widget, instead is (radius + thumbRadius) * 2.
  final double radius;

  /// radius of thumb.
  final double thumbRadius;

  /// thumb stroke color.
  final Color thumbStrokeColor;

  /// A listener receives color pick events.
  final ColorListener colorListener;

  /// initial color of this color picker.
  final Color initialColor;

  /// Child widget
  final Widget? child;

  CircleColorPicker({
    Key? key,
    this.radius = 160,
    this.initialColor = const Color(0xffff0000),
    this.thumbStrokeColor = Colors.white,
    this.thumbRadius = 8,
    this.child,
    required this.colorListener,
  }) : super(key: key);

  @override
  State<CircleColorPicker> createState() {
    return _CircleColorPickerState();
  }
}

class _CircleColorPickerState extends State<CircleColorPicker> {
  static const List<Color> colors = [
    Color(0xffff0000),
    Color(0xffff4000),
    Color(0xffff8000),
    Color(0xffffbf00),
    Color(0xffffff00),
    Color(0xffbfff00),
    Color(0xff80ff00),
    Color(0xff40ff00),
    Color(0xff00ff00),
    Color(0xff00ff40),
    Color(0xff00ff80),
    Color(0xff00ffbf),
    Color(0xff00ffff),
    Color(0xff00bfff),
    Color(0xff0080ff),
    Color(0xff0040ff),
    Color(0xff0000ff),
    Color(0xff4000ff),
    Color(0xff8000ff),
    Color(0xffbf00ff),
    Color(0xffff00ff),
    Color(0xffff00bf),
    Color(0xffff0080),
    Color(0xffff0040),
  ];

  late double thumbDistanceToCenter;
  late double thumbRadians;
  late Color color;

  @override
  void initState() {
    super.initState();
    thumbDistanceToCenter = widget.radius - widget.thumbRadius;
    final double hue = HSVColor.fromColor(widget.initialColor).hue;
    thumbRadians = degreesToRadians(270 - hue);
    color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final double radius = widget.radius;
    final double thumbRadius = widget.thumbRadius;

    // compute thumb center coordinate
    final double thumbCenterX =
        radius + thumbDistanceToCenter * sin(thumbRadians);
    final double thumbCenterY =
        radius + thumbDistanceToCenter * cos(thumbRadians);

    // build thumb widget
    Widget thumb = Positioned(
        left: thumbCenterX,
        top: thumbCenterY,
        child: Container(
          width: thumbRadius * 2,
          height: thumbRadius * 2,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
              border: Border.all(
                  color: widget.thumbStrokeColor, width: thumbRadius * 0.25),
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(thumbRadius))),
        ));
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (details) => handleTouch(details.globalPosition, context),
        onPanStart: (details) => handleTouch(details.globalPosition, context),
        onPanUpdate: (details) => handleTouch(details.globalPosition, context),
        child: Stack(
          children: <Widget>[
            SizedBox(
                width: (radius + thumbRadius) * 2,
                height: (radius + thumbRadius) * 2),
            Positioned(
              left: thumbRadius,
              top: thumbRadius,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(radius)),
                    gradient: SweepGradient(colors: colors)),
              ),
            ),
            Positioned(
              left: thumbRadius * 3,
              top: thumbRadius * 3,
              child: Container(
                width: (radius - thumbRadius * 2) * 2,
                height: (radius - thumbRadius * 2) * 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius - thumbRadius * 2),
                  ),
                ),
                child: Center(child: widget.child ?? Container()),
              ),
            ),
            thumb
          ],
        ));
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(Offset globalPosition, BuildContext context) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(globalPosition);
    final double centerX = box.size.width / 2;
    final double centerY = box.size.height / 2;
    final double deltaX = localPosition.dx - centerX;
    final double deltaY = localPosition.dy - centerY;
    double theta = atan2(deltaX, deltaY);
    double degree = 270 - radiansToDegrees(theta);
    if (degree < 0) degree = 360 + degree;
    widget.colorListener(HSVColor.fromAHSV(1, degree, 1, 1).toColor());
    setState(() {
      thumbDistanceToCenter = widget.radius - widget.thumbRadius;
      thumbRadians = theta;
      color = HSVColor.fromAHSV(1, degree, 1, 1).toColor();
    });
  }

  /// convert an angle value from radian to degree representation.
  double radiansToDegrees(double radians) {
    return (radians + pi) / pi * 180;
  }

  /// convert an angle value from degree to radian representation.
  double degreesToRadians(double degrees) {
    return degrees / 180 * pi - pi;
  }
}
