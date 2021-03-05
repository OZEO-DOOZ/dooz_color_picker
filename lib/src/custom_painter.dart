import 'dart:math';
import 'package:flutter/material.dart';

class CircleProgressBarPainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> foregroundColors;

  CircleProgressBarPainter({
    @required this.foregroundColors,
    double strokeWidth,
  }) : this.strokeWidth = strokeWidth ?? 6;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        size - Offset(this.strokeWidth, this.strokeWidth);
    final shortestSide = min(constrainedSize.width, constrainedSize.height);
    final radius = (shortestSide / 2);
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    final s = SweepGradient(
      colors: foregroundColors,
      startAngle: pi / 2 - pi / 4,
      endAngle: pi * 2 - pi / 4,
      transform: GradientRotation(pi / 2),
    );
    final foregroundPaint = Paint()
      ..shader = s.createShader(rect)
      ..strokeWidth = this.strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Start at the top. 0 radians represents the right edge
    final double startAngle = pi / 2 - pi / 4 + pi / 2;
    final double sweepAngle = pi * 2 - pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as CircleProgressBarPainter);
    return oldPainter.foregroundColors != this.foregroundColors ||
        oldPainter.strokeWidth != this.strokeWidth;
  }
}
