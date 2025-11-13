import 'package:flutter/material.dart';
import 'article_detail_screen.dart';

class TopicArticlesScreen extends StatefulWidget {
  final String topicTitle;
  final List<Map<String, String>> articles;

  const TopicArticlesScreen({
    super.key,
    required this.topicTitle,
    required this.articles,
  });

  @override
  State<TopicArticlesScreen> createState() => _TopicArticlesScreenState();
}

class _TopicArticlesScreenState extends State<TopicArticlesScreen> {
  late List<Map<String, String>> _items;
  int _generatedCount = 0;

  @override
  void initState() {
    super.initState();
    _items = List<Map<String, String>>.from(widget.articles);
    // ensure at least 6 items are shown initially; if not, generate mock ones
    if (_items.length < 6) {
      _generateMockArticles(6 - _items.length);
    }
  }

  void _generateMockArticles(int n) {
    final base = _items.length + _generatedCount;
    for (var i = 0; i < n; i++) {
      final idx = base + i + 1;
      _items.add({
        'title': '${widget.topicTitle} — Extra Article $idx',
        'subtitle':
            'Automatically generated preview for ${widget.topicTitle.toLowerCase()} (item $idx).',
      });
    }
    _generatedCount += n;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicTitle),
        backgroundColor: const Color(0xFF7ED321),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = _items[index];
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(article['title'] ?? ''),
            subtitle: Text(article['subtitle'] ?? ''),
            onTap: () {
              final id = article['id'];
              if (id != null && id.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(articleId: id),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generateMockArticles(5),
        backgroundColor: const Color(0xFF7ED321),
        label: const Text('Generate more'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
