import 'package:flutter/material.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  // Sample forum data with more realistic content
  final List<ForumPost> forumPosts = [
    ForumPost(
      id: 1,
      title: 'What helps you reset after a bad day?',
      author: 'SeekingBalance',
      content:
          'Had one of those days where everything went wrong. Lost my keys, spilled coffee on my shirt, and got stuck in traffic. How do you guys bounce back from rough days like this?',
      comments: [
        Comment(
          author: 'ZenMaster22',
          content:
              'I take a hot shower and listen to calming music. It\'s like washing the day away.',
        ),
        Comment(
          author: 'MindfulMom',
          content:
              'Gratitude list! Write down 3 good things, even tiny ones. It shifts my perspective.',
        ),
        Comment(
          author: 'NightOwl',
          content:
              'Early bedtime with a good book. Tomorrow is always a fresh start.',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    ForumPost(
      id: 2,
      title: 'I feel like I\'m always behind — how do you stay motivated?',
      author: 'StrugglingSenior',
      content:
          'Everyone around me seems to have their life together while I\'m barely keeping up. How do you maintain motivation when you feel like you\'re constantly playing catch-up?',
      comments: [
        Comment(
          author: 'WiseOwl',
          content:
              'Comparison is the thief of joy. Focus on your own journey, not others\' highlight reels.',
        ),
        Comment(
          author: 'GradStudent2024',
          content:
              'Small daily wins! I celebrate completing even tiny tasks. Progress is progress.',
        ),
        Comment(
          author: 'LifeCoachSarah',
          content:
              'Try time-blocking your day. When you plan ahead, you feel more in control.',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ForumPost(
      id: 3,
      title: 'Any good podcasts or books for mental health?',
      author: 'BookwormSeeker',
      content:
          'Looking for recommendations on podcasts, books, or resources that have genuinely helped your mental health journey. What\'s been your game-changer?',
      comments: [
        Comment(
          author: 'PodcastFan',
          content:
              'The Happiness Lab is amazing! Science-backed tips for wellbeing.',
        ),
        Comment(
          author: 'ReadingRainbow',
          content:
              'Atomic Habits by James Clear changed how I approach self-improvement.',
        ),
        Comment(
          author: 'TherapistTom',
          content:
              'Feeling Good by David Burns - excellent for understanding thought patterns.',
        ),
        Comment(
          author: 'AudiobookLover',
          content:
              'Mindfulness apps like Headspace have guided meditations that really help.',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    ForumPost(
      id: 4,
      title: 'Dealing with social anxiety at work meetings',
      author: 'QuietProfessional',
      content:
          'I freeze up during team meetings and can barely speak. My ideas are good but I can\'t seem to voice them. Any tips for managing social anxiety in professional settings?',
      comments: [
        Comment(
          author: 'PublicSpeaker',
          content:
              'Practice your main points beforehand. Having a mental script helps me feel prepared.',
        ),
        Comment(
          author: 'IntrovertPower',
          content:
              'Arrive early and chat with a few people. It makes the room feel less intimidating.',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ForumPost(
      id: 5,
      title: 'Building healthy habits that actually stick',
      author: 'HabitHunter',
      content:
          'I start strong with new routines but always fall off after a week or two. What are some daily habits that have genuinely improved your mental health long-term?',
      comments: [
        Comment(
          author: 'MorningWarrior',
          content:
              'Morning sunlight walk - even 10 minutes. It regulates my mood and sleep cycle.',
        ),
        Comment(
          author: 'JournalJourney',
          content:
              'Gratitude journal before bed. Just 3 things I\'m thankful for each day.',
        ),
        Comment(
          author: 'MindfulEater',
          content:
              'Mindful eating! Putting away devices during meals helps me feel more present.',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ForumPost(
      id: 6,
      title: 'Celebrating small wins today! 🌟',
      author: 'PositiveProgress',
      content:
          'Made my bed, replied to three emails, and took a 15-minute walk. Some days the smallest actions feel like major victories. What small wins are you celebrating?',
      comments: [
        Comment(
          author: 'CheerleaderSoul',
          content: 'YES! Those moments matter so much. Proud of you! 💪',
        ),
        Comment(
          author: 'RecoveryRoad',
          content: 'This perspective is everything. Every step forward counts.',
        ),
        Comment(
          author: 'MotivatedMike',
          content:
              'You\'re inspiring me to notice my own small victories. Thank you!',
        ),
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  void _showPostDetails(ForumPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
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

          // Forum posts list
          Expanded(
            child: ListView.builder(
              itemCount: forumPosts.length,
              itemBuilder: (context, index) {
                final post = forumPosts[index];
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
                          color: index.isEven
                              ? Colors.white
                              : const Color(0xFFF0F9F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index.isEven
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
                              color: index.isEven
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
                            // Post title
                            Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Post meta info
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  post.author,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _timeAgo(post.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.comment_outlined,
                                  size: 14,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.comments.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Post preview content
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

                            // Expandable indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Tap to expand',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.withValues(alpha: 0.7),
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        widget.post.comments.add(
          Comment(author: 'You', content: _commentController.text.trim()),
        );
      });
      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added! 💬'),
          backgroundColor: Colors.green,
        ),
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
  final int id;
  final String title;
  final String author;
  final String content;
  final List<Comment> comments;
  final DateTime timestamp;

  ForumPost({
    required this.id,
    required this.title,
    required this.author,
    required this.content,
    required this.comments,
    required this.timestamp,
  });
}

class Comment {
  final String author;
  final String content;

  Comment({required this.author, required this.content});
}
