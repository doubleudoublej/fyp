import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  DateTime currentDate = DateTime.now();
  DateTime selectedDate = DateTime.now(); // The date selected for mood entry
  String selectedMood = '😊';
  TextEditingController journalController = TextEditingController();

  // Sample mood data for demonstration (in real app, this would come from database)
  Map<DateTime, Map<String, dynamic>> moodData = {
    DateTime(2025, 9, 1): {'mood': '😊', 'journal': 'Great day at work!'},
    DateTime(2025, 9, 2): {
      'mood': '😐',
      'journal': 'Average day, nothing special',
    },
    DateTime(2025, 9, 3): {'mood': '😔', 'journal': 'Felt a bit down today'},
    DateTime(2025, 9, 4): {'mood': '😊', 'journal': 'Good morning workout!'},
    DateTime(2025, 9, 5): {'mood': '😍', 'journal': 'Amazing day with friends'},
    DateTime(2025, 9, 6): {'mood': '😐', 'journal': 'Work was stressful'},
    DateTime(2025, 9, 7): {'mood': '😔', 'journal': 'Rainy day blues'},
    DateTime(2025, 9, 8): {'mood': '😊', 'journal': 'Family time was nice'},
    DateTime(2025, 9, 9): {'mood': '😤', 'journal': 'Traffic was terrible'},
    DateTime(2025, 9, 10): {'mood': '😊', 'journal': 'Productive day'},
    DateTime(2025, 9, 11): {'mood': '😍', 'journal': 'Got promoted!'},
    DateTime(2025, 9, 12): {'mood': '😐', 'journal': 'Regular Thursday'},
    DateTime(2025, 9, 13): {'mood': '😊', 'journal': 'Weekend plans made'},
    DateTime(2025, 9, 14): {'mood': '😤', 'journal': 'Argument with colleague'},
  };

  List<String> moodEmojis = ['😊', '😐', '😔', '😍', '😤', '😱', '🤮'];
  List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  void saveMoodEntry() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Prevent saving mood entries for future dates
    if (selectedDate.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save mood entries for future dates!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate that mood is selected
    if (selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a mood first!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final entryDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    setState(() {
      moodData[entryDate] = {
        'mood': selectedMood,
        'journal': journalController.text.trim(),
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          entryDate.isAtSameMomentAs(today)
              ? 'Today\'s mood entry saved!'
              : 'Mood entry saved for ${_formatShortDate(entryDate)}!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Clear journal input after saving
    journalController.clear();
  }

  Widget buildCalendar() {
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final startCalendar = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
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
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    currentDate = DateTime(
                      currentDate.year,
                      currentDate.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
              Text(
                "${_getMonthName(currentDate.month)}'${currentDate.year.toString().substring(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    currentDate = DateTime(
                      currentDate.year,
                      currentDate.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right, size: 28),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Week day headers
          Row(
            children: weekDays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final date = startCalendar.add(
                  Duration(days: weekIndex * 7 + dayIndex),
                );
                final isCurrentMonth = date.month == currentDate.month;
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, selectedDate);
                final isFuture = date.isAfter(DateTime.now());
                final mood =
                    moodData[DateTime(date.year, date.month, date.day)];

                return Expanded(
                  child: GestureDetector(
                    onTap: isCurrentMonth && !isFuture
                        ? () {
                            setState(() {
                              selectedDate = date;
                              // Load existing data for this date if available
                              final existingEntry =
                                  moodData[DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                  )];
                              if (existingEntry != null) {
                                selectedMood = existingEntry['mood'] ?? '😊';
                                journalController.text =
                                    existingEntry['journal'] ?? '';
                              } else {
                                selectedMood = '😊';
                                journalController.text = '';
                              }
                            });
                          }
                        : null,
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.5)
                            : isToday
                            ? Colors.blue.withValues(alpha: 0.3)
                            : isCurrentMonth
                            ? (mood != null
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.transparent)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: isFuture
                                  ? Colors.grey.withValues(alpha: 0.5)
                                  : isCurrentMonth
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (mood != null && isCurrentMonth)
                            Text(
                              mood['mood'],
                              style: const TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget buildMoodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: moodEmojis.map((emoji) {
          final isSelected = selectedMood == emoji;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMood = emoji;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue.withValues(alpha: 0.3)
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isSelectedToday = _isSameDay(selectedDate, today);
    final selectedFormattedDate = isSelectedToday
        ? "${_getDayName(today.weekday)} ${today.day} ${_getMonthName(today.month)} ${today.year}"
        : "${_getDayName(selectedDate.weekday)} ${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFF7ED321),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const Text(
                    'Mood Tracker',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Calendar
                    buildCalendar(),

                    const SizedBox(height: 20),

                    // Selected date mood section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFormattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Feeling',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedMood,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Mood selector
                          const Text(
                            'How are you feeling today?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood emoji selector
                    buildMoodSelector(),

                    const SizedBox(height: 20),

                    // Journal section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Journal Entry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'What caused you to feel this way?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Journal text field
                          TextField(
                            controller: journalController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  'Write about your day, thoughts, or feelings...',
                              hintStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: saveMoodEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Entry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            ),

            // Bottom Navigation (index 3 = Profile since it's accessed from profile)
            const CustomBottomNavigationBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  String _getDayName(int weekday) {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday];
  }

  String _formatShortDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}';
  }
}
