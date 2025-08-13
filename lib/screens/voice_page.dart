import 'package:flutter/material.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  bool isRecording = false;
  bool isGiftAnimating = false;
  late AnimationController _giftController;
  late Animation<double> _giftFallAnimation;
  late Animation<double> _giftOpenAnimation;

  @override
  void initState() {
    super.initState();
    _giftController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _giftFallAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _giftController,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );

    _giftOpenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _giftController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _giftController.dispose();
    super.dispose();
  }

  void startRecording() {
    setState(() {
      isRecording = true;
    });

    // Mock recording for 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice message recorded! 🎤'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void triggerGiftDrop() {
    setState(() {
      isGiftAnimating = true;
    });

    _giftController.forward().then((_) {
      // Show gift message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎁 Gift Message: You are amazing! ✨'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 4),
        ),
      );

      // Reset animation after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _giftController.reset();
          setState(() {
            isGiftAnimating = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Voice header
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Voice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Gifted Tree Section
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Make tree take up most of available space
                final treeHeight = constraints.maxHeight * 0.8;
                final treeWidth = constraints.maxWidth * 0.9;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tree illustration - much larger
                    CustomPaint(
                      size: Size(treeWidth, treeHeight),
                      painter: GiftedTreePainter(),
                    ),

                    // Animated gift drop - starts from tree branch
                    if (isGiftAnimating)
                      AnimatedBuilder(
                        animation: _giftFallAnimation,
                        builder: (context, child) {
                          // Gift starts from tree branch position, falls down
                          final startY = treeHeight * 0.3; // Tree branch level
                          final endY = treeHeight * 0.9; // Bottom of screen
                          final currentY =
                              startY +
                              (_giftFallAnimation.value * (endY - startY));

                          return Positioned(
                            top: currentY,
                            child: AnimatedBuilder(
                              animation: _giftOpenAnimation,
                              builder: (context, child) {
                                // Gift disappears when opened
                                if (_giftOpenAnimation.value > 0.8) {
                                  return const SizedBox.shrink(); // Remove gift
                                }

                                return Transform.scale(
                                  scale: 1.0 + (_giftOpenAnimation.value * 0.5),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _giftOpenAnimation.value > 0.5
                                          ? Colors.yellow
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _giftOpenAnimation.value > 0.5
                                            ? '✨'
                                            : '🎁',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Record button
              Expanded(
                child: GestureDetector(
                  onTap: isRecording ? null : startRecording,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.red.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRecording ? 'Recording...' : 'Record',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Get button
              Expanded(
                child: GestureDetector(
                  onTap: isGiftAnimating ? null : triggerGiftDrop,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: isGiftAnimating
                          ? Colors.grey.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isGiftAnimating
                                ? Icons.hourglass_empty
                                : Icons.card_giftcard,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isGiftAnimating ? 'Getting...' : 'Get',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Custom painter for the gifted tree
class GiftedTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Scale tree elements based on canvas size - reduce size to fit screen
    final centerX = size.width / 2;
    final bottomY = size.height * 0.90; // Move closer to bottom
    final trunkWidth = size.width * 0.08; // Slightly narrower trunk
    final trunkHeight = size.height * 0.3; // Shorter trunk
    final mainFoliageRadius = size.width * 0.25; // Smaller main foliage
    final sideFoliageRadius = size.width * 0.16; // Smaller side foliage

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
    final giftSize = size.width * 0.035; // Smaller gifts proportional to tree
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
