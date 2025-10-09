import 'package:flutter/material.dart';

class RewardDialog extends StatelessWidget {
  final int pointsAwarded;
  const RewardDialog({super.key, this.pointsAwarded = 100});

  @override
  Widget build(BuildContext context) {
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
            // Animated present icon (keeps a simple scale animation via TweenAnimationBuilder)
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
                          color: const Color(0xFF7ED321).withValues(alpha: 0.4),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                '+$pointsAwarded Bonus Points!',
                style: const TextStyle(
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
  }
}
