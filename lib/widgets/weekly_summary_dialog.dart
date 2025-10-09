import 'package:flutter/material.dart';

class WeeklySummaryDialog extends StatelessWidget {
  final Map<int, List<Map<String, dynamic>>> weeklyActivities;
  final int weeklyTotal;

  const WeeklySummaryDialog({
    super.key,
    required this.weeklyActivities,
    required this.weeklyTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Weekly Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total points: $weeklyTotal'),
            const SizedBox(height: 12),
            const Text(
              'Daily breakdown:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(7, (i) {
              final dayIndex = i + 1;
              final dayName = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ][i];
              final list = weeklyActivities[dayIndex] ?? [];
              final dayTotal = list.fold<int>(
                0,
                (s, e) => s + (e['points'] as int? ?? 0),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(dayName), Text('$dayTotal pts')],
                    ),
                    if (list.isNotEmpty)
                      ...list.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 6),
                          child: Text(
                            '- ${a['desc']}: ${a['points']} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 6),
                        child: Text(
                          '- No activity',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7ED321),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
