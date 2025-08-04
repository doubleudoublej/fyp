import 'package:flutter/material.dart';

class ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw tree trunks
    paint.color = const Color(0xFF8B4513); // Brown
    for (int i = 0; i < 7; i++) {
      final x = (i * size.width / 6) + 20;
      canvas.drawRect(Rect.fromLTWH(x, size.height - 40, 15, 40), paint);
    }

    // Draw tree tops (green circles)
    paint.color = const Color(0xFF228B22); // Forest green
    for (int i = 0; i < 7; i++) {
      final x = (i * size.width / 6) + 27.5;
      canvas.drawCircle(Offset(x, size.height - 50), 25, paint);
    }

    // Add some variation in tree heights and colors
    paint.color = const Color(0xFF32CD32); // Lime green
    for (int i = 1; i < 6; i += 2) {
      final x = (i * size.width / 6) + 27.5;
      canvas.drawCircle(Offset(x, size.height - 45), 20, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
