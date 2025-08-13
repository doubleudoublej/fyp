import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/articles_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/activities_screen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Colors.black),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home button (index 0)
          _buildNavButton(
            context: context,
            icon: Icons.home,
            color: Colors.orange,
            isSelected: currentIndex == 0,
            onTap: () {
              if (currentIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
          ),

          // Activities button (index 1) - Voice & Text activities
          _buildNavButton(
            context: context,
            icon: Icons.track_changes,
            color: Colors.red,
            isSelected: currentIndex == 1,
            onTap: () {
              if (currentIndex != 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActivitiesScreen(),
                  ),
                );
              }
            },
          ),

          // Articles button (index 2)
          _buildNavButton(
            context: context,
            icon: Icons.menu_book,
            color: Colors.blue,
            isSelected: currentIndex == 2,
            onTap: () {
              if (currentIndex != 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArticlesScreen(),
                  ),
                );
              }
            },
          ),

          // Profile button (index 3)
          _buildNavButton(
            context: context,
            icon: Icons.person,
            color: Colors.grey,
            isSelected: currentIndex == 3,
            onTap: () {
              if (currentIndex != 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Icon(
          icon,
          color: isSelected && color == Colors.grey
              ? Colors
                    .black // Special case for profile when selected
              : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
