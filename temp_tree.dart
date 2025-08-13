import 'package:flutter/material.dart';

// Custom painter for the gifted tree
class GiftedTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Scale tree elements based on canvas size - make it bigger
    final centerX = size.width / 2;
    final bottomY = size.height * 0.85; // Move up slightly to fit better
    final trunkWidth = size.width * 0.1; // Wider trunk
    final trunkHeight = size.height * 0.4; // Taller trunk
    final mainFoliageRadius = size.width * 0.35; // Much larger main foliage
    final sideFoliageRadius = size.width * 0.22; // Larger side foliage

    // Draw tree trunk
    paint.color = const Color(0xFF8B4513); // Brown
    final trunkRect = Rect.fromCenter(
      center: Offset(centerX, bottomY - trunkHeight / 2),
      width: trunkWidth,
      height: trunkHeight,
    );
    canvas.drawRect(trunkRect, paint);

    // Draw main tree foliage (large green circle)
    paint.color = const Color(0xFF228B22); // Forest green
    final foliageY = bottomY - trunkHeight - mainFoliageRadius * 0.6;
    canvas.drawCircle(Offset(centerX, foliageY), mainFoliageRadius, paint);

    // Draw smaller foliage circles for depth
    paint.color = const Color(0xFF32CD32); // Lime green
    final sideY = foliageY - mainFoliageRadius * 0.25;
    canvas.drawCircle(
      Offset(centerX - mainFoliageRadius * 0.6, sideY),
      sideFoliageRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + mainFoliageRadius * 0.6, sideY),
      sideFoliageRadius,
      paint,
    );

    // Draw gifts hanging on the tree branches - scale with tree size
    final giftSize = size.width * 0.05; // Larger gifts
    final giftPositions = [
      Offset(
        centerX - mainFoliageRadius * 0.5,
        foliageY - mainFoliageRadius * 0.2,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.5,
        foliageY - mainFoliageRadius * 0.2,
      ),
      Offset(centerX, foliageY - mainFoliageRadius * 0.7),
      Offset(
        centerX - mainFoliageRadius * 0.25,
        foliageY + mainFoliageRadius * 0.3,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.25,
        foliageY + mainFoliageRadius * 0.3,
      ),
      Offset(
        centerX - mainFoliageRadius * 0.8,
        foliageY + mainFoliageRadius * 0.4,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.8,
        foliageY + mainFoliageRadius * 0.4,
      ),
      Offset(centerX, foliageY + mainFoliageRadius * 0.6),
    ];

    for (int i = 0; i < giftPositions.length; i++) {
      final giftColors = [
        Colors.red,
        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.cyan,
      ];
      paint.color = giftColors[i % giftColors.length];

      // Draw gift box
      final giftRect = Rect.fromCenter(
        center: giftPositions[i],
        width: giftSize,
        height: giftSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(giftRect, Radius.circular(giftSize * 0.1)),
        paint,
      );

      // Draw gift ribbon
      paint.color = Colors.yellow;
      paint.strokeWidth = giftSize * 0.12;
      canvas.drawLine(
        Offset(giftPositions[i].dx - giftSize / 2, giftPositions[i].dy),
        Offset(giftPositions[i].dx + giftSize / 2, giftPositions[i].dy),
        paint,
      );
      canvas.drawLine(
        Offset(giftPositions[i].dx, giftPositions[i].dy - giftSize / 2),
        Offset(giftPositions[i].dx, giftPositions[i].dy + giftSize / 2),
        paint,
      );
      paint.strokeWidth = 1;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
