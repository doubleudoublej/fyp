import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _breathingController;
  late AnimationController _particleController;
  late AnimationController _textController;

  Timer? _navigationTimer;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Breathing animation for the central wellness symbol
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Floating particles animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Setup animations
    _setupAnimations();

    // Start animations with mounted checks
    if (mounted) {
      _breathingController.repeat(reverse: true);
      _particleController.repeat();
      _mainController.forward();
    }

    // Start text animation after a delay
    Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textController.forward();
      }
    });

    // Navigate to home after 5 seconds
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void _setupAnimations() {
    // Fade in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Scale animation for the main symbol
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Breathing animation
    _breathingAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Rotation animation for particles
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Slide animation for text
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
        );

    // Progress animation
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mainController.stop();
    _breathingController.stop();
    _particleController.stop();
    _textController.stop();
    _mainController.dispose();
    _breathingController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7ED321), // Your app's green
              Color(0xFF9AE84A), // Lighter green
              Color(0xFFB8F569), // Even lighter green
              Color(0xFFE8F5E8), // Very light green/white
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainController,
              _breathingController,
              _particleController,
              _textController,
            ]),
            builder: (context, child) {
              return Stack(
                children: [
                  // Background floating particles
                  ...List.generate(12, (index) {
                    final angle = (index * 30.0) * (math.pi / 180);
                    final radius = 100.0 + (index * 20.0);
                    final animationOffset =
                        (_rotationAnimation.value + (index * 0.2)) % 1.0;

                    return Positioned(
                      left:
                          MediaQuery.of(context).size.width / 2 +
                          math.cos(angle + _rotationAnimation.value) * radius -
                          8,
                      top:
                          MediaQuery.of(context).size.height / 2 +
                          math.sin(angle + _rotationAnimation.value) * radius -
                          8,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 4 + (animationOffset * 8),
                          height: 4 + (animationOffset * 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.6 + (animationOffset * 0.4),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main wellness symbol with breathing animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ScaleTransition(
                            scale: _breathingAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Inner growing circles
                                  ...List.generate(3, (index) {
                                    final delay = index * 0.3;
                                    final scale =
                                        (_breathingAnimation.value - delay)
                                            .clamp(0.0, 1.0);
                                    return Container(
                                      width: 40 + (index * 20) * scale,
                                      height: 40 + (index * 20) * scale,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF7ED321)
                                              .withValues(
                                                alpha: 0.3 - (index * 0.1),
                                              ),
                                          width: 2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),

                                  // Central wellness icon
                                  const Icon(
                                    Icons
                                        .psychology, // Brain/mental health icon
                                    size: 50,
                                    color: Color(0xFF7ED321),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // App title with slide animation
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _textController,
                            child: Column(
                              children: [
                                const Text(
                                  'Mental Health',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Companion',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8.0,
                                        color: Colors.black26,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Your journey to wellness starts here',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Progress indicator
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Custom progress bar
                              Container(
                                width: 200,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Loading text
                              Text(
                                'Preparing your wellness space...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Pulsing dots
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.2;
                              final animation =
                                  Tween<double>(begin: 0.3, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: _breathingController,
                                      curve: Interval(
                                        delay,
                                        0.8 + delay,
                                        curve: Curves.easeInOut,
                                      ),
                                    ),
                                  );

                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: animation.value,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
