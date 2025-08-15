import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/forest_painter.dart';
import '../widgets/bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rewardAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // User progress data (this would normally come from a state management solution)
  int currentPoints = 1250; // From profile page
  int progressCount = 7; // Out of 20 dots (7/20 = 35% progress)
  bool isRewardAvailable = false;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkRewardStatus();
  }

  void _setupAnimations() {
    _rewardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _rewardAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rewardAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  void _checkRewardStatus() {
    // Check if progress is complete (20/20 dots filled)
    setState(() {
      isRewardAvailable = progressCount >= 20;
    });
  }

  void _claimReward() async {
    if (!isRewardAvailable || isAnimating) return;

    setState(() {
      isAnimating = true;
    });

    await _rewardAnimationController.forward();

    // Show reward popup
    if (mounted) {
      _showRewardDialog();
    }

    // Reset progress and animation
    await Future.delayed(const Duration(milliseconds: 500));
    _rewardAnimationController.reset();

    setState(() {
      progressCount = 0;
      currentPoints += 100; // Bonus points for completing the circle
      isRewardAvailable = false;
      isAnimating = false;
    });
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated present icon
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.5 + (value * 0.5),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7ED321),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF7ED321,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.card_giftcard,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  '🎉 Congratulations! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7ED321),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'You\'ve completed your wellness circle!',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    '+100 Bonus Points!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7ED321),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _rewardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7ED321), // Bright green background
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top section with greeting and progress
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Greeting text
                          const Text(
                            'Hello Jay,',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Progress Circle with animated present
                          GestureDetector(
                            onTap: _claimReward,
                            child: AnimatedBuilder(
                              animation: _rewardAnimationController,
                              builder: (context, child) {
                                return SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Progress ring background
                                      CustomPaint(
                                        size: const Size(200, 200),
                                        painter: CirclePainter(),
                                      ),
                                      // Present icon (animated when reward is available)
                                      Transform.scale(
                                        scale: isAnimating
                                            ? _scaleAnimation.value
                                            : (isRewardAvailable ? 1.1 : 1.0),
                                        child: Transform.rotate(
                                          angle: isAnimating
                                              ? _rotationAnimation.value
                                              : 0.0,
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: isRewardAvailable
                                                  ? const Color(
                                                      0xFFFFD700,
                                                    ) // Gold when ready
                                                  : Colors.orange,
                                              shape: BoxShape.circle,
                                              boxShadow: isRewardAvailable
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            const Color(
                                                              0xFFFFD700,
                                                            ).withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        blurRadius: 15,
                                                        spreadRadius: 3,
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Icon(
                                              Icons.card_giftcard,
                                              color: Colors.white,
                                              size: isRewardAvailable ? 35 : 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Progress dots
                                      ...List.generate(20, (index) {
                                        final angle =
                                            (index * 18.0) * math.pi / 180;
                                        final radius = 90.0;
                                        final x = radius * math.cos(angle);
                                        final y = radius * math.sin(angle);

                                        return Positioned(
                                          left: 100 + x - 6,
                                          top: 100 + y - 6,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: index < progressCount
                                                  ? const Color(0xFFFFD700)
                                                  : Colors.grey.withValues(
                                                      alpha: 0.3,
                                                    ),
                                              shape: BoxShape.circle,
                                              boxShadow: index < progressCount
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            const Color(
                                                              0xFFFFD700,
                                                            ).withValues(
                                                              alpha: 0.5,
                                                            ),
                                                        blurRadius: 4,
                                                        spreadRadius: 1,
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                          ),
                                        );
                                      }),
                                      // Progress indicator text
                                      if (!isRewardAvailable)
                                        Positioned(
                                          bottom: -10,
                                          child: Text(
                                            '$progressCount/20',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      // "Tap to claim" text when reward is ready
                                      if (isRewardAvailable && !isAnimating)
                                        Positioned(
                                          bottom: -10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFD700),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: const Text(
                                              'Tap to claim!',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Updated points display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFFFD700),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$currentPoints Wellness Points',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7ED321),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Forest illustration
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(painter: ForestPainter()),
                    ),

                    // Task cards
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          // Task 1 Card
                          GestureDetector(
                            onTap: () {
                              // Simulate task completion
                              setState(() {
                                if (progressCount < 20) {
                                  progressCount++;
                                  currentPoints += 50;
                                  _checkRewardStatus();
                                }
                              });

                              // Show completion feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Task completed! +50 points',
                                  ),
                                  backgroundColor: const Color(0xFF7ED321),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: progressCount >= 20
                                      ? const Color(0xFFFFD700)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7ED321),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.mood,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Daily Mood Check',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          '50 points',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Complete your daily mood tracker to earn wellness points.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Task 2 Card
                          GestureDetector(
                            onTap: () {
                              // Simulate task completion
                              setState(() {
                                if (progressCount < 20) {
                                  progressCount++;
                                  currentPoints += 20;
                                  _checkRewardStatus();
                                }
                              });

                              // Show completion feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Article read! +20 points',
                                  ),
                                  backgroundColor: Colors.blue,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: progressCount >= 20
                                      ? const Color(0xFFFFD700)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.menu_book,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Read Article',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Text(
                                          '20 points',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Read a mental health article to expand your knowledge.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Test button for quick progress (only in development)
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                progressCount = 20; // Fill the circle instantly
                                _checkRewardStatus();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('🎯 Fill Progress (Test)'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            const CustomBottomNavigationBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
