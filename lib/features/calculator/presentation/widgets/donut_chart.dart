import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 22.0;

    final segments = [
      {'color': const Color(0xFF3730D8), 'sweep': 0.55}, // Net income - blue
      {'color': const Color(0xFF22C55E), 'sweep': 0.25}, // Green
      {'color': const Color(0xFFE5E7EB), 'sweep': 0.20}, // Gray
    ];

    double startAngle = -math.pi / 2;

    for (final segment in segments) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = segment['color'] as Color;

      final sweepAngle = (segment['sweep'] as double) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}