import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/forum_service.dart';
import '../services/auth_service.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final ForumService _forumService = ForumService();
  final AuthService _authService = AuthService();

  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _newContentController = TextEditingController();

  void _showPostDetails(ForumPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  String _timeAgoFromIso(String iso) => ForumService.timeAgoFromIso(iso);

  @override
  void dispose() {
    _newTitleController.dispose();
    _newContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Text header
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Text',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Forum header with icons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.forum, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Icon(Icons.chat_bubble_outline, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Icon(Icons.people_outline, color: Colors.orange, size: 20),
                SizedBox(width: 16),
                Text(
                  'Forum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // New post input
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _newTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Post title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newContentController,
                  decoration: const InputDecoration(
                    hintText: 'Share something supportive...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = _authService.currentUser;
                          final title = _newTitleController.text.trim();
                          final content = _newContentController.text.trim();
                          final messenger = ScaffoldMessenger.of(context);
                          if (user == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please sign in to post'),
                              ),
                            );
                            return;
                          }
                          if (title.isEmpty || content.isEmpty) return;
                          await _forumService.createPost(
                            authorUid: user.uid,
                            author:
                                user.displayName ?? user.email ?? 'Anonymous',
                            title: title,
                            content: content,
                          );
                          _newTitleController.clear();
                          _newContentController.clear();
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Post submitted')),
                          );
                        },
                        child: const Text('Post to forum'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Forum posts list (realtime)
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _forumService.postsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final value = snapshot.data!.snapshot.value;
                final List<ForumPost> posts = [];
                if (value is Map) {
                  final entries = value.entries.toList()
                    ..sort((a, b) {
                      final ta = (a.value as Map)['timestamp'] ?? '';
                      final tb = (b.value as Map)['timestamp'] ?? '';
                      return tb.toString().compareTo(ta.toString());
                    });
                  for (final e in entries) {
                    final k = e.key.toString();
                    final Map postMap = Map<String, dynamic>.from(
                      e.value as Map,
                    );
                    final title = postMap['title']?.toString() ?? '';
                    final author = postMap['author']?.toString() ?? 'Anonymous';
                    final content = postMap['content']?.toString() ?? '';
                    final timestamp =
                        postMap['timestamp']?.toString() ??
                        DateTime.now().toIso8601String();
                    final comments = <Comment>[];
                    if (postMap['comments'] is Map) {
                      final cm = postMap['comments'] as Map;
                      final cEntries = cm.entries.toList()
                        ..sort((a, b) {
                          final ta = (a.value as Map)['timestamp'] ?? '';
                          final tb = (b.value as Map)['timestamp'] ?? '';
                          return ta.toString().compareTo(tb.toString());
                        });
                      for (final c in cEntries) {
                        final cmMap = Map<String, dynamic>.from(c.value as Map);
                        comments.add(
                          Comment(
                            author: cmMap['author']?.toString() ?? 'Anonymous',
                            content: cmMap['content']?.toString() ?? '',
                            timestampIso: cmMap['timestamp']?.toString(),
                          ),
                        );
                      }
                    }
                    posts.add(
                      ForumPost(
                        id: k,
                        title: title,
                        author: author,
                        content: content,
                        comments: comments,
                        timestampIso: timestamp,
                      ),
                    );
                  }
                }

                if (posts.isEmpty) {
                  return const Center(
                    child: Text('No posts yet — be the first to share!'),
                  );
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final even = index.isEven;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showPostDetails(post),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: even
                                  ? Colors.white
                                  : const Color(0xFFF0F9F0),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: even
                                    ? const Color(0xFFE0E0E0)
                                    : const Color(
                                        0xFF4CAF50,
                                      ).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                                BoxShadow(
                                  color: even
                                      ? Colors.blue.withValues(alpha: 0.05)
                                      : Colors.green.withValues(alpha: 0.05),
                                  spreadRadius: 0,
                                  blurRadius: 12,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      post.author,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _timeAgoFromIso(
                                        post.timestampIso ??
                                            DateTime.now().toIso8601String(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 14,
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.comments.length}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.content.length > 100
                                      ? '${post.content.substring(0, 100)}...'
                                      : post.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Tap to expand',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.expand_more,
                                      size: 16,
                                      color: Colors.blue.withValues(alpha: 0.7),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Post detail screen (full-screen expanded view)
class PostDetailScreen extends StatefulWidget {
  final ForumPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ForumService _forumService = ForumService();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to comment')),
      );
      return;
    }

    // Optimistically add to UI
    setState(() {
      widget.post.comments.add(
        Comment(
          author: user.displayName ?? user.email ?? 'You',
          content: text,
          timestampIso: DateTime.now().toIso8601String(),
        ),
      );
    });
    _commentController.clear();

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _forumService.addComment(
        postId: widget.post.id,
        authorUid: user.uid,
        author: user.displayName ?? user.email ?? 'Anonymous',
        content: text,
      );
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Comment added! 💬'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7ED321),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7ED321),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.post.author,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.post.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comments section
                  Text(
                    'Comments (${widget.post.comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Comments list
                  ...widget.post.comments.map((comment) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                comment.author,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.content,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Comment input section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a supportive comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: Color(0xFF7ED321)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _addComment,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7ED321),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
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

// Data models
class ForumPost {
  final String id;
  final String title;
  final String author;
  final String content;
  final List<Comment> comments;
  final String? timestampIso;

  ForumPost({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.comments,
    required this.timestampIso,
  });
}

class Comment {
  final String author;
  final String content;
  final String? timestampIso;

  Comment({required this.author, required this.content, this.timestampIso});
}
