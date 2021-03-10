import 'dart:math';
import 'package:flutter/material.dart';

typedef GradientSliderOnChange = void Function(int value);

/// A bar color picker
class GradientSlider extends StatefulWidget {
  /// background Color
  final List<Color> colors;

  /// width of bar
  final double width;

  /// width of bar
  final double height;

  /// A listener receives value (0 => 100).
  final GradientSliderOnChange onChange;

  /// thumb fill color
  final Color thumbColor;

  /// radius of thumb
  final double thumbWidth;

  /// init value
  final int initValue;

  GradientSlider({
    Key key,
    this.colors = const [Colors.white, Colors.black],
    this.width = 200,
    this.height = 16,
    this.thumbWidth = 20,
    this.thumbColor = Colors.white,
    this.initValue = 50,
    @required this.onChange,
  })  : assert(width != null),
        assert(initValue >= 0 && initValue <= 100),
        assert(onChange != null),
        super(key: key);

  @override
  _GradientSliderState createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  double percent = 0.0;

  @override
  void initState() {
    percent = widget.initValue / 100;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double thumbLeft, thumbTop;
    thumbLeft = (widget.width - widget.thumbWidth) * percent;

    Widget frame = Container(width: widget.width, height: widget.thumbWidth);

    // build thumb
    Widget thumb = Positioned(
        left: thumbLeft,
        top: thumbTop,
        child: Container(
          width: widget.thumbWidth,
          height: widget.thumbWidth,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
              color: widget.thumbColor,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.thumbWidth / 2))),
        ));
    Widget content = Positioned(
      left: 0,
      top: (widget.thumbWidth - widget.height) / 2,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ],
            borderRadius: BorderRadius.all(Radius.circular(widget.height / 2)),
            gradient: LinearGradient(colors: widget.colors)),
      ),
    );

    return GestureDetector(
      onPanDown: (details) => handleTouch(details.globalPosition, context),
      onPanStart: (details) => handleTouch(details.globalPosition, context),
      onPanUpdate: (details) => handleTouch(details.globalPosition, context),
      child: Stack(
        children: [frame, content, thumb],
      ),
    );
  }

  /// calculate colors picked from palette and update our states.
  void handleTouch(Offset globalPosition, BuildContext context) {
    RenderBox box = context.findRenderObject();
    Offset localPosition = box.globalToLocal(globalPosition);
    double percent;
    percent = localPosition.dx / (widget.width);
    percent = min(max(0.0, percent), 1.0);
    setState(() {
      this.percent = percent;
    });
    widget.onChange((percent * 100).toInt());
  }
}
