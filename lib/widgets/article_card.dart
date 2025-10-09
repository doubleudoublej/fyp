import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, String> article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7ED321).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
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
            Text(
              article['subtitle']!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
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
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 16, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  article['readTime']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
