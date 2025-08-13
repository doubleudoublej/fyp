import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'mood_tracker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7ED321), // Same green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Name and Points headers
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Points',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Personal info rows with alternating colors
                    Expanded(
                      child: Column(
                        children: [
                          // Row 1 - Green
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.lightGreen.withValues(alpha: 0.6),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Personal info stuff',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),

                          // Row 2 - Light grey
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Personal info stuff',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),

                          // Row 3 - Green (Mood Tracker - clickable)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MoodTrackerScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mood,
                                      color: Colors.black54,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mood Tracker',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black54,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Large green section
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.withValues(alpha: 0.6),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),

                          // Next schedule section
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: const Center(
                              child: Text(
                                'Next schedule with doc',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Custom Bottom Navigation (index 3 = Profile)
            const CustomBottomNavigationBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}
