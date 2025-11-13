import 'package:flutter/material.dart';
import '../widgets/forest_painter.dart';
import '../widgets/bottom_navigation_bar.dart';
// Removed debug test widget import
import '../widgets/weekly_progress_ring.dart';
import '../widgets/weekly_summary_dialog.dart';
import '../widgets/reward_dialog.dart';
import '../widgets/task_card.dart';
import '../widgets/points_badge.dart';
import '../services/points_service.dart';
import '../services/auth_service.dart';
import '../models/weekly_activities.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _rewardAnimationController;
  StreamSubscription<int>? _pointsSub;

  // User progress data (this would normally come from a state management solution)
  int currentPoints = 1250; // From profile page
  bool isRewardAvailable = false;
  bool isAnimating = false;

  // Weekly challenge config
  final int weeklyGoal = 500;
  final List<int> milestones = [100, 200, 350, 500];

  // Use sample data from model (replace with backend/real data later)
  Map<int, List<Map<String, dynamic>>> get weeklyActivities =>
      sampleWeeklyActivities;
  int get _weeklyTotal => computeWeeklyTotal(weeklyActivities);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkRewardStatus();
    // Listen for live points when user is signed in
    final auth = AuthService();
    final pts = PointsService();
    final user = auth.currentUser;
    if (user != null) {
      _pointsSub = pts.pointsStream(user.uid).listen((value) {
        setState(() => currentPoints = value);
      });

      // Ensure DB and local initial value are in sync. If DB is empty (0)
      // but the app has a seeded `currentPoints` (e.g. from local state during
      // development), persist it so other screens read the same value.
      pts
          .getPoints(user.uid)
          .then((dbPoints) {
            if (dbPoints == 0 && currentPoints > 0) {
              // populate DB with local points
              pts.setPoints(user.uid, currentPoints);
            } else if (dbPoints > 0 && dbPoints != currentPoints) {
              // adopt DB as source-of-truth
              setState(() => currentPoints = dbPoints);
            }
          })
          .catchError((_) {});
    }
  }

  void _setupAnimations() {
    _rewardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Reward animation controller is used as a timing mechanism when claiming a reward
    // Specific scale/rotation animations were removed in favor of the new ring UI.
  }

  void _checkRewardStatus() {
    // Check reward eligibility from weekly total
    setState(() {
      isRewardAvailable = _weeklyTotal >= weeklyGoal;
    });
  }

  void _addActivity(String desc, int points) {
    // Add an activity for today and update points and reward status
    final int weekday = DateTime.now().weekday; // 1 = Monday .. 7 = Sunday
    sampleWeeklyActivities.putIfAbsent(weekday, () => []);
    sampleWeeklyActivities[weekday]!.add({'desc': desc, 'points': points});
    currentPoints += points;
    _checkRewardStatus();
    // Persist points to Realtime Database so other screens (Profile) stay in sync.
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        // Fire-and-forget; attach a catchError so failures (eg permission denied)
        // don't become unhandled exceptions in the app.
        PointsService().addPoints(user.uid, points).catchError((e) {
          // Optionally log or show a message in debug mode.
          if (kDebugMode) debugPrint('addPoints failed: $e');
        });
      }
    } catch (_) {}
  }

  // Weekday label removed — center label now shows the weekly TARGET

  void _showWeeklySummaryDialog() {
    showDialog(
      context: context,
      builder: (_) => WeeklySummaryDialog(
        weeklyActivities: weeklyActivities,
        weeklyTotal: _weeklyTotal,
      ),
    );
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
      // clear weekly activities (reset progress) and award bonus
      sampleWeeklyActivities.updateAll(
        (key, value) => <Map<String, dynamic>>[],
      );
      currentPoints += 100; // Bonus points for completing the circle
      isRewardAvailable = false;
      isAnimating = false;
    });
    // Also persist awarded bonus to DB so profile/home stay in sync
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        await PointsService().addPoints(user.uid, 100);
      }
    } catch (_) {}
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RewardDialog(pointsAwarded: 100),
    );
  }

  @override
  void dispose() {
    _rewardAnimationController.dispose();
    _pointsSub?.cancel();
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
                          // Health test button removed

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
                                      // New gradient progress ring (animated)
                                      // Use reusable WeeklyProgressRing widget
                                      WeeklyProgressRing(
                                        size: 200,
                                        weeklyGoal: weeklyGoal,
                                        weeklyTotal: _weeklyTotal,
                                        milestones: milestones,
                                        strokeWidth: 30,
                                        onCenterTap: _showWeeklySummaryDialog,
                                        centerLabel: 'TARGET',
                                      ),

                                      // Milestones and center are now rendered by WeeklyProgressRing
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 20),
                          // Updated points display (extracted)
                          PointsBadge(points: currentPoints),
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
                          TaskCard(
                            title: 'Daily Mood Check',
                            subtitle:
                                'Complete your daily mood tracker to earn wellness points.',
                            icon: Icons.mood,
                            iconColor: const Color(0xFF7ED321),
                            pointsLabel: '50 points',
                            highlighted: isRewardAvailable,
                            onTap: () {
                              _addActivity('Daily Mood Check', 50);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Task completed! +50 points'),
                                  backgroundColor: Color(0xFF7ED321),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),

                          TaskCard(
                            title: 'Read Article',
                            subtitle:
                                'Read a mental health article to expand your knowledge.',
                            icon: Icons.menu_book,
                            iconColor: Colors.blue,
                            pointsLabel: '20 points',
                            highlighted: isRewardAvailable,
                            onTap: () {
                              _addActivity('Read Article', 20);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Article read! +20 points'),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),

                          // Development-only Fill Progress button removed
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
