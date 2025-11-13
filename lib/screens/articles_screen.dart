import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/article_card.dart';
import 'topic_articles_screen.dart';
import 'article_detail_screen.dart';
import '../services/articles_service.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  int currentArticleIndex = 0;
  final PageController _pageController = PageController();
  Timer? _autoAdvanceTimer;

  // Local sample articles used for seeding Firestore if collection is empty.
  final List<Map<String, dynamic>> _sampleArticles = [
    {
      'id': 'anxiety-guide',
      'title': 'Understanding Anxiety: A Guide to Managing Daily Stress',
      'subtitle': 'Learn practical techniques to cope with anxiety',
      'author': 'Dr. Sarah Chen, Clinical Psychologist',
      'readTime': '5 min read',
      'category': 'Anxiety Management',
      'content':
          'Anxiety is a normal human response to stress. In this article we explore practical techniques such as paced breathing, grounding exercises, and cognitive reframing to manage daily anxious thoughts. Start by identifying triggers and building a routine that includes short mindfulness breaks. Seek professional help when anxiety interferes with daily functioning.',
    },
    {
      'id': 'sleep-habits',
      'title': 'Building Healthy Sleep Habits for Better Mental Health',
      'subtitle': 'The connection between sleep and emotional wellbeing',
      'author': 'Dr. Michael Rodriguez, Sleep Specialist',
      'readTime': '7 min read',
      'category': 'Self-Care',
      'content':
          'Good sleep supports mood, memory, and overall health. This article covers sleep hygiene: regular sleep schedule, limiting screens before bed, and creating a restful environment. Small changes like dimming lights and reducing caffeine after mid-afternoon can lead to meaningful improvements.',
    },
    {
      'id': 'recognizing-depression',
      'title': 'Recognizing Depression: When to Seek Professional Help',
      'subtitle': 'Understanding the signs and finding support',
      'author': 'Dr. Lisa Thompson, Psychiatrist',
      'readTime': '6 min read',
      'category': 'Depression Support',
      'content':
          'Depression can present as persistent low mood, loss of interest, changes in appetite or sleep, and thoughts of hopelessness. Early recognition and reaching out to a professional can make treatment more effective. This article outlines screening tips and ways to approach conversations with loved ones.',
    },
    {
      'id': 'mindfulness-techniques',
      'title': 'Mindfulness Techniques for Everyday Stress Relief',
      'subtitle': 'Simple practices to center yourself throughout the day',
      'author': 'Dr. James Park, Mindfulness Coach',
      'readTime': '4 min read',
      'category': 'Mindfulness',
      'content':
          'Mindfulness is the practice of paying attention to the present moment with curiosity. Try a 2-minute body scan, mindful walking, or focussed breathing. Consistent short practices build resilience and reduce rumination over time.',
    },
    {
      'id': 'communication-relationships',
      'title': 'Improving Communication in Relationships',
      'subtitle': 'Building stronger connections through better dialogue',
      'author': 'Dr. Emma Watson, Relationship Therapist',
      'readTime': '8 min read',
      'category': 'Relationships',
      'content':
          'Healthy communication involves active listening, expressing needs clearly, and using "I" statements. This article offers strategies to reduce conflict, set boundaries, and practice empathy to strengthen relationships.',
    },
  ];

  final ArticlesService _articlesService = ArticlesService();
  List<Map<String, dynamic>> _articles = [];
  bool _loadingArticles = true;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
    _loadArticles();
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      final fetched = await _articlesService.fetchArticleMetadata();
      // Do NOT auto-seed Storage with local placeholders. If fetch returns
      // empty, prefer showing local sample articles in the UI but avoid
      // writing them into the user's bucket automatically. Seeding should be
      // an explicit admin action.
      setState(() {
        _articles = fetched.isEmpty ? _sampleArticles : fetched;
        _loadingArticles = false;
      });
    } catch (e) {
      // on error fall back to sample articles locally
      setState(() {
        _articles = _sampleArticles;
        _loadingArticles = false;
      });
    }
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted && _articles.isNotEmpty) {
        _nextArticle();
      }
    });
  }

  void _nextArticle() {
    if (_articles.isEmpty) return;
    setState(() {
      currentArticleIndex = (currentArticleIndex + 1) % _articles.length;
    });
    _pageController.animateToPage(
      currentArticleIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousArticle() {
    if (_articles.isEmpty) return;
    setState(() {
      currentArticleIndex = currentArticleIndex > 0
          ? currentArticleIndex - 1
          : _articles.length - 1;
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
            // Header with manual refresh
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Articles',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  // manual refresh button to re-fetch from Storage
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh articles from Storage',
                    onPressed: () async {
                      if (!mounted) return;
                      setState(() {
                        _loadingArticles = true;
                      });
                      try {
                        final fetched = await _articlesService
                            .fetchArticleMetadata();
                        if (!mounted) return;
                        setState(() {
                          _articles = fetched.isEmpty
                              ? _sampleArticles
                              : fetched;
                          _loadingArticles = false;
                        });
                        if (!mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              fetched.isEmpty
                                  ? 'No articles found in Storage — using local samples.'
                                  : 'Articles refreshed from Storage.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        setState(() {
                          _articles = _sampleArticles;
                          _loadingArticles = false;
                        });
                        if (!mounted) return;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to refresh articles.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _loadingArticles
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // "Recco Article" title
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Recommended Articles',
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
                                    itemCount: _articles.length,
                                    itemBuilder: (context, index) {
                                      final article = _articles[index];
                                      final safeArticle = {
                                        'title':
                                            article['title']?.toString() ?? '',
                                        'subtitle':
                                            article['subtitle']?.toString() ??
                                            '',
                                        'author':
                                            article['author']?.toString() ?? '',
                                        'readTime':
                                            article['readTime']?.toString() ??
                                            '',
                                        'category':
                                            article['category']?.toString() ??
                                            '',
                                        'content':
                                            article['content']?.toString() ??
                                            '',
                                      };
                                      return ArticleCard(
                                        article: safeArticle,
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ArticleDetailScreen(
                                                    articleId: article['id']
                                                        ?.toString(),
                                                  ),
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
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
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
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        _articles.length,
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
                              animationDuration: const Duration(
                                milliseconds: 300,
                              ),
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
                        ), // end Column
                      ), // end SingleChildScrollView
              ), // end Padding
            ), // end Expanded
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
    // gather articles matching the topic using a small keyword map so categories
    // like "Mindfulness" or "Self-Care" can match the "Self-care" panel.
    bool articleMatchesTopic(Map<String, dynamic> a, String topicTitle) {
      final cat = (a['category'] ?? '').toString().toLowerCase();
      final t = topicTitle.toLowerCase();
      final Map<String, List<String>> keywords = {
        'anxiety': ['anxiety'],
        'depression': ['depression'],
        'self-care': [
          'self-care',
          'selfcare',
          'mindfulness',
          'self care',
          'stress',
        ],
        'relationships': ['relationship', 'relationships'],
      };
      final keys = keywords.entries
          .firstWhere(
            (e) => e.key == t || e.key.startsWith(t),
            orElse: () => MapEntry(t, [t]),
          )
          .value;
      return keys.any((k) => cat.contains(k));
    }

    final matches = _articles
        .where((a) => articleMatchesTopic(a, title))
        .toList();
    final previews = matches.isEmpty
        ? _articles.take(3).toList()
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
                  onTap: () {
                    final id = article['id']?.toString();
                    if (id != null && id.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailScreen(articleId: id),
                        ),
                      );
                    }
                  },
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
                        articles: (matches.isEmpty ? _articles : matches)
                            .map(
                              (a) => {
                                'id': a['id']?.toString() ?? '',
                                'title': a['title']?.toString() ?? '',
                                'subtitle': a['subtitle']?.toString() ?? '',
                              },
                            )
                            .toList(),
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
