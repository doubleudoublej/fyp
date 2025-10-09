import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/article_card.dart';
import 'topic_articles_screen.dart';
// topic buttons are replaced by accordion list; topic_button import no longer needed

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
                              return ArticleCard(
                                article: article,
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

                    // Topics accordion: four headers, each expands to show three previews + '... more'
                    ExpansionPanelList.radio(
                      expandedHeaderPadding: EdgeInsets.zero,
                      animationDuration: const Duration(milliseconds: 300),
                      children: [
                        _buildTopicPanel(
                          'anxiety',
                          'Anxiety',
                          Icons.psychology_outlined,
                          Colors.blue,
                        ),
                        _buildTopicPanel(
                          'depression',
                          'Depression',
                          Icons.favorite_outline,
                          Colors.purple,
                        ),
                        _buildTopicPanel(
                          'selfcare',
                          'Self-care',
                          Icons.spa_outlined,
                          Colors.green,
                        ),
                        _buildTopicPanel(
                          'relationships',
                          'Relationships',
                          Icons.people_outline,
                          Colors.orange,
                        ),
                      ],
                      // ExpansionPanelList.radio manages single-expanded behavior
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

  ExpansionPanelRadio _buildTopicPanel(
    String key,
    String title,
    IconData icon,
    Color color,
  ) {
    // gather three sample articles matching the topic by simple category contains test
    final matches = articles
        .where(
          (a) => a['category']!.toLowerCase().contains(
            title.toLowerCase().split('-').first,
          ),
        )
        .toList();
    final previews = matches.isEmpty
        ? articles.take(3).toList()
        : matches.take(3).toList();

    return ExpansionPanelRadio(
      value: key,
      headerBuilder: (context, isExpanded) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, bottom: 12),
        child: Column(
          children: [
            // three preview tiles
            for (var article in previews)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(article['title'] ?? ''),
                  subtitle: Text(article['subtitle'] ?? ''),
                  onTap: () {},
                ),
              ),
            // more button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TopicArticlesScreen(
                        topicTitle: title,
                        articles: matches.isEmpty ? articles : matches,
                      ),
                    ),
                  );
                },
                child: const Text('... more'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
