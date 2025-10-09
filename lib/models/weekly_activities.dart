// Sample model for weekly activities and a helper to compute total points
final Map<int, List<Map<String, dynamic>>> sampleWeeklyActivities = {
  1: [
    {'desc': 'Mood tracker', 'points': 50},
    {'desc': 'Read article', 'points': 20},
  ],
  2: [
    {'desc': 'Guided breathing', 'points': 30},
  ],
  3: [
    {'desc': 'Daily mood', 'points': 50},
    {'desc': 'Activity', 'points': 20},
  ],
  4: [],
  5: [
    {'desc': 'Daily mood', 'points': 50},
    {'desc': 'Article', 'points': 20},
  ],
  6: [
    {'desc': 'Quick check', 'points': 30},
  ],
  7: [],
};

int computeWeeklyTotal(Map<int, List<Map<String, dynamic>>> activities) {
  int total = 0;
  for (final list in activities.values) {
    for (final a in list) {
      total += (a['points'] as int?) ?? 0;
    }
  }
  return total;
}
