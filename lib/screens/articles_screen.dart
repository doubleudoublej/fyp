import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/bottom_navigation_bar.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  int currentArticleIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoAdvanceTimer;

  final List<Map<String, String>> articles = [
    {
      'title': 'Understanding Anxiety: A Guide to Managing Daily Stress',
      'subtitle': 'Learn practical techniques to cope with anxiety',
      'author': 'Dr. Sarah Chen, Clinical Psychologist',
      'readTime': '5 min read',
      'category': 'Anxiety Management',
    },
    {
      'title': 'Building Healthy Sleep Habits for Better Mental Health',
      'subtitle': 'The connection between sleep and emotional wellbeing',
      'author': 'Dr. Michael Rodriguez, Sleep Specialist',
      'readTime': '7 min read',
      'category': 'Self-Care',
    },
    {
      'title': 'Recognizing Depression: When to Seek Professional Help',
      'subtitle': 'Understanding the signs and finding support',
      'author': 'Dr. Lisa Thompson, Psychiatrist',
      'readTime': '6 min read',
      'category': 'Depression Support',
    },
    {
      'title': 'Mindfulness Techniques for Everyday Stress Relief',
      'subtitle': 'Simple practices to center yourself throughout the day',
      'author': 'Dr. James Park, Mindfulness Coach',
      'readTime': '4 min read',
      'category': 'Mindfulness',
    },
    {
      'title': 'Improving Communication in Relationships',
      'subtitle': 'Building stronger connections through better dialogue',
      'author': 'Dr. Emma Watson, Relationship Therapist',
      'readTime': '8 min read',
      'category': 'Relationships',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        _nextArticle();
      }
    });
  }

  void _nextArticle() {
    setState(() {
      currentArticleIndex = (currentArticleIndex + 1) % articles.length;
    });
    _pageController.animateToPage(
      currentArticleIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousArticle() {
    setState(() {
      currentArticleIndex = currentArticleIndex > 0
          ? currentArticleIndex - 1
          : articles.length - 1;
    });
    _pageController.animateToPage(
      currentArticleIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _resetAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    _startAutoAdvance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7ED321), // Same green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Text(
                    'Articles',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // "Recco Article" title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recco Article',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Large content area with navigation arrows
                    Container(
                      height: 200, // Reduced from 220 to save space
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // PageView for articles
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                currentArticleIndex = index;
                              });
                              _resetAutoAdvanceTimer(); // Reset timer on manual swipe
                            },
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final article = articles[index];
                              return GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Opening: ${article['title']}',
                                      ),
                                      backgroundColor: const Color(0xFF7ED321),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF7ED321,
                                          ).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          article['category']!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF7ED321),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Article title
                                      Text(
                                        article['title']!,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),

                                      // Subtitle
                                      Text(
                                        article['subtitle']!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),

                                      // Author and read time
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              article['author']!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.black45,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            article['readTime']!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Left arrow - always visible for continuous loop
                          Positioned(
                            left: 10,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                _previousArticle();
                                _resetAutoAdvanceTimer(); // Reset timer on manual navigation
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Right arrow - always visible for continuous loop
                          Positioned(
                            right: 10,
                            top: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                _nextArticle();
                                _resetAutoAdvanceTimer(); // Reset timer on manual navigation
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // Page indicators
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                articles.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: currentArticleIndex == index
                                        ? const Color(0xFF7ED321)
                                        : Colors.black26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Mental Health Topic buttons in 2x2 grid - back to scrolling
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: [
                          // Anxiety
                          _buildTopicButton(
                            'Anxiety',
                            Icons.psychology_outlined,
                            Colors.blue.withValues(alpha: 0.8),
                            'Learn coping strategies and techniques for managing anxiety',
                          ),

                          // Depression
                          _buildTopicButton(
                            'Depression',
                            Icons.favorite_outline,
                            Colors.purple.withValues(alpha: 0.8),
                            'Understanding depression and finding support resources',
                          ),

                          // Self-care
                          _buildTopicButton(
                            'Self-care',
                            Icons.spa_outlined,
                            Colors.green.withValues(alpha: 0.8),
                            'Practical self-care tips for mental and physical wellbeing',
                          ),

                          // Relationships
                          _buildTopicButton(
                            'Relationships',
                            Icons.people_outline,
                            Colors.orange.withValues(alpha: 0.8),
                            'Building healthy connections and communication skills',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Custom Bottom Navigation (index 2 = Articles)
            const CustomBottomNavigationBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicButton(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exploring $title resources...'),
            backgroundColor: const Color(0xFF7ED321),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Back to original padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50, // Back to original size
                height: 50, // Back to original size
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ), // Back to original size
              ),
              const SizedBox(height: 12), // Back to original spacing
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Larger text
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // Back to original spacing
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12, // Larger text
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 3, // More lines for longer descriptions
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
