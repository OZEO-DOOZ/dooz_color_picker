import 'dart:math';

import 'package:flutter/material.dart';
import 'custom_painter.dart';

/// A listener which receives an color in int representation. as used
/// by [CircleColorPicker.colorListener].
typedef ColorTemperatureListener = void Function(Color color, int kDegree);

/// A circle palette color picker.
class CircleTemperaturePicker extends StatefulWidget {
  // radius of the color palette, note that radius * 2 is not the final
  // width of this widget, instead is (radius + thumbRadius) * 2.
  final double radius;

  /// radius of thumb.
  final double thumbRadius;

  /// thumb stroke color.
  final Color thumbStrokeColor;

  /// A listener receives color pick events.
  final ColorTemperatureListener colorListener;

  /// Start Temperature (geater than 1500)
  final int startTemperature;

  /// End Temperature (less than 40000)
  final int endTemperature;

  /// initial Temperature of this picker.
  final int initialTemperature;

  /// Child widget
  final Widget? child;

  CircleTemperaturePicker(
      {Key? key,
      this.radius = 160,
      this.thumbRadius = 8,
      this.initialTemperature = 2600,
      this.thumbStrokeColor = Colors.white,
      this.startTemperature = 2600,
      this.endTemperature = 10600,
      this.child,
      required this.colorListener})
      : assert(startTemperature > 1500),
        assert(endTemperature < 40000),
        assert(initialTemperature >= startTemperature &&
            initialTemperature <= endTemperature),
        super(key: key);

  @override
  State<CircleTemperaturePicker> createState() {
    return _TemperaturePickerState();
  }
}

class _TemperaturePickerState extends State<CircleTemperaturePicker> {
  List<Color> colors = [];

  late double thumbDistanceToCenter;
  late double thumbRadians;
  late int colorIndex;

  @override
  void initState() {
    super.initState();
    colors = generateColorsFormKelvin(
        widget.startTemperature, widget.endTemperature);
    thumbDistanceToCenter = widget.radius - widget.thumbRadius;
    int initColor = colors.indexWhere(
        (element) => element == getColorFromKelvin(widget.initialTemperature));
    if (initColor == colors.length - 1) initColor = colors.length;
    final degree = 180 - ((270 / colors.length * initColor)) - 45;
    colorIndex = initColor;
    thumbRadians = degreesToRadians(degree);
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
              color: colors[colorIndex],
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
            Positioned(
              left: thumbRadius,
              top: thumbRadius,
              child: Container(
                width: radius * 2,
                height: radius * 2,
                child: CustomPaint(
                  foregroundPainter: CircleProgressBarPainter(
                    foregroundColors: colors,
                    strokeWidth: thumbRadius * 2,
                  ),
                ),
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
    double degree = (180 - radiansToDegrees(theta)).roundToDouble();
    final degreePindex = 270 / colors.length;
    if (degree < 0) degree = 360 + degree;
    if (degree <= 44) return;
    if (degree >= 316) return;

    int index = ((degree - 45) ~/ degreePindex).toInt();
    if (index < 0) index = 0;
    if (index >= colors.length) index = colors.length - 1;
    final kDegree = widget.startTemperature + 100 * colorIndex;
    widget.colorListener(colors[index.toInt()], kDegree);
    setState(() {
      thumbDistanceToCenter = widget.radius - widget.thumbRadius;
      thumbRadians = theta;
      colorIndex = index.toInt();
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

  List<Color> generateColorsFormKelvin(int start, int end) {
    List<Color> returnValue = [];
    int flag = start;
    while (flag <= end) {
      final tempColor = getColorFromKelvin(flag);
      returnValue.add(tempColor);
      flag += 100;
    }
    return returnValue;
  }
}

Color getColorFromKelvin(int k) {
  double tmpCalc;
  double tmpKelvin = k.toDouble();
  if (tmpKelvin < 1000) tmpKelvin = 1000;
  if (tmpKelvin > 40000) tmpKelvin = 40000;
  tmpKelvin = tmpKelvin / 100;

  // Red
  double r;
  if (tmpKelvin <= 66) {
    r = 255;
  } else {
    tmpCalc = tmpKelvin - 60;
    tmpCalc = 329.698727446 * pow(tmpCalc, -0.1332047592);
    r = tmpCalc;
    if (r < 0) r = 0;
    if (r > 255) r = 255;
  }
  // Green
  double g;
  if (tmpKelvin <= 66) {
    tmpCalc = tmpKelvin;
    tmpCalc = 99.4708025861 * log(tmpCalc) - 161.1195681661;
    g = tmpCalc;
    if (g < 0) g = 0;
    if (g > 255) g = 255;
  } else {
    tmpCalc = tmpKelvin - 60;
    tmpCalc = 288.1221695283 * pow(tmpCalc, -0.0755148492);
    g = tmpCalc;
    if (g < 0) g = 0;
    if (g > 255) g = 255;
  }
// Blue
  double b;
  if (tmpKelvin >= 66) {
    b = 255;
  } else if (tmpKelvin <= 19) {
    b = 0;
  } else {
    tmpCalc = tmpKelvin - 10;
    tmpCalc = 138.5177312231 * log(tmpCalc) - 305.0447927307;
    b = tmpCalc;
    if (b < 0) b = 0;
    if (b > 255) b = 255;
  }
  return Color.fromRGBO(r.toInt(), g.toInt(), b.toInt(), 1);
}
