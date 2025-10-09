import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeeklyProgressRing extends StatefulWidget {
  final double size;
  final int weeklyGoal;
  final int weeklyTotal;
  final List<int> milestones;
  final double strokeWidth;
  final VoidCallback? onCenterTap;
  final String centerLabel;

  const WeeklyProgressRing({
    super.key,
    required this.size,
    required this.weeklyGoal,
    required this.weeklyTotal,
    required this.milestones,
    this.strokeWidth = 30,
    this.onCenterTap,
    this.centerLabel = 'TARGET',
  });

  @override
  State<WeeklyProgressRing> createState() => _WeeklyProgressRingState();
}

class _WeeklyProgressRingState extends State<WeeklyProgressRing> {
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousProgress = (widget.weeklyTotal / widget.weeklyGoal).clamp(
      0.0,
      1.0,
    );
  }

  @override
  void didUpdateWidget(covariant WeeklyProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldProgress = (oldWidget.weeklyTotal / oldWidget.weeklyGoal).clamp(
      0.0,
      1.0,
    );
    _previousProgress = oldProgress;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.weeklyTotal / widget.weeklyGoal).clamp(0.0, 1.0);
    final size = widget.size;
    final strokeWidth = widget.strokeWidth;
    // Milestone and painter start angle (hard-coded to top)
    const startAngle = -math.pi / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _previousProgress, end: progress),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _GradientRingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                ),
              );
            },
          ),

          // Milestones
          ...List.generate(widget.milestones.length, (i) {
            final milestone = widget.milestones[i];
            final fraction = milestone / widget.weeklyGoal;
            final angle = startAngle + 2 * math.pi * fraction;
            // compute radius consistent with painter
            final radius = (size / 2) - strokeWidth / 2 - 6;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);
            final reached = widget.weeklyTotal >= milestone;
            final isTreasure = milestone == widget.weeklyGoal;

            return Positioned(
              left: size / 2 + x - 14,
              top: size / 2 + y - 14,
              child: AnimatedScale(
                scale: reached ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: reached
                        ? const Color(0xFFFFD700)
                        : Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: reached
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.45),
                              blurRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: isTreasure
                        ? Icon(
                            reached
                                ? Icons.workspace_premium
                                : Icons.workspace_premium,
                            size: 16,
                            color: reached ? Colors.white : Colors.white70,
                          )
                        : (reached
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.monetization_on,
                                  size: 16,
                                  color: Colors.white70,
                                )),
                  ),
                ),
              ),
            );
          }),

          // Center area
          GestureDetector(
            onTap: widget.onCenterTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.weeklyTotal >= widget.weeklyGoal
                      ? Icons.inventory_2
                      : Icons.star,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.centerLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                if (widget.weeklyTotal >= widget.weeklyGoal)
                  Column(
                    children: const [
                      Icon(Icons.celebration, color: Colors.white, size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Week Won!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '${widget.weeklyGoal - widget.weeklyTotal} pts left',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  _GradientRingPainter({required this.progress, this.strokeWidth = 30});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (math.min(size.width, size.height) / 2) - strokeWidth / 2 - 6;

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    // Hard-code start angle at the top (-pi/2) so the arc always begins
    // at 12 o'clock. Use a solid color for the completed arc.
    const startAngle = -math.pi / 2;
    final arcColor = progress >= 1.0
        ? const Color(0xFFFFD700)
        : const Color(0xFF0072FF);
    final fgPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = strokeWidth;

    final start = startAngle;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
