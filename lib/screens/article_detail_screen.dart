import 'package:flutter/material.dart';
import '../services/articles_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ArticleDetailScreen extends StatefulWidget {
  /// Either provide `article` map (already fetched) or an `articleId` to fetch.
  final Map<String, dynamic>? article;
  final String? articleId;
  const ArticleDetailScreen({super.key, this.article, this.articleId})
    : assert(article != null || articleId != null);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticlesService _service = ArticlesService();
  Map<String, dynamic>? _article;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _article = widget.article;
    } else if (widget.articleId != null) {
      _fetchArticle(widget.articleId!);
    }
  }

  Future<void> _fetchArticle(String id) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final a = await _service.getArticleById(id);
      if (mounted) {
        setState(() {
          _article = a;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load article. (${e.toString()})';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Article'),
          backgroundColor: const Color(0xFF7ED321),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.articleId != null)
                        _fetchArticle(widget.articleId!);
                    },
                    child: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7ED321),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final title = _article?['title'] ?? 'Article';
    final subtitle = _article?['subtitle'] ?? '';
    final author = _article?['author'] ?? '';
    final readTime = _article?['readTime'] ?? '';
    final content = _article?['content'] ?? 'No content available.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7ED321),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(author, style: const TextStyle(color: Colors.black45)),
                  const SizedBox(width: 12),
                  Text(readTime, style: const TextStyle(color: Colors.black45)),
                ],
              ),
              const SizedBox(height: 20),
              // Render markdown for richer article formatting
              MarkdownBody(data: content),
            ],
          ),
        ),
      ),
    );
  }
}
