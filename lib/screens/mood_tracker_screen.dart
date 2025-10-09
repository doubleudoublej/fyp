import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/mood_calendar.dart';

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
    DateTime(2025, 8, 1): {'mood': '😊', 'journal': 'Great start to August!'},
    DateTime(2025, 8, 2): {
      'mood': '😐',
      'journal': 'Average day, nothing special',
    },
    DateTime(2025, 8, 3): {'mood': '😔', 'journal': 'Felt a bit down today'},
    DateTime(2025, 8, 4): {'mood': '😊', 'journal': 'Good morning workout!'},
    DateTime(2025, 8, 5): {'mood': '😍', 'journal': 'Amazing day with friends'},
    DateTime(2025, 8, 6): {'mood': '😐', 'journal': 'Work was stressful'},
    DateTime(2025, 8, 7): {'mood': '😔', 'journal': 'Rainy day blues'},
    DateTime(2025, 8, 8): {'mood': '😊', 'journal': 'Family time was nice'},
    DateTime(2025, 8, 9): {'mood': '😤', 'journal': 'Traffic was terrible'},
    DateTime(2025, 8, 10): {'mood': '😊', 'journal': 'Productive day'},
    DateTime(2025, 8, 11): {'mood': '😍', 'journal': 'Weekend was great!'},
    DateTime(2025, 8, 12): {'mood': '😐', 'journal': 'Regular Monday'},
    DateTime(2025, 8, 13): {'mood': '😊', 'journal': 'Mid-week progress'},
    DateTime(2025, 8, 14): {'mood': '�', 'journal': 'Almost weekend!'},
    DateTime(2025, 8, 15): {'mood': '😊', 'journal': 'Today feels good'},
  };

  List<String> moodEmojis = ['😊', '😐', '😔', '😍', '😤', '😱', '🤮'];
  List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() {
    journalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize to the device's current month
    final now = DateTime.now();
    currentDate = DateTime(now.year, now.month);
    // Ensure selectedDate starts as today
    selectedDate = DateTime(now.year, now.month, now.day);
    // Filter out any future mood data that might exist
    _filterPastMoodData();
  }

  // Method to ensure only past and current mood data is kept
  void _filterPastMoodData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Remove any mood entries that are in the future
    moodData.removeWhere((date, data) => date.isAfter(today));
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

  // buildCalendar moved to MoodCalendar widget

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
                    MoodCalendar(
                      currentMonth: currentDate,
                      selectedDate: selectedDate,
                      moodData: moodData,
                      onDateSelected: (date) {
                        setState(() {
                          selectedDate = date;
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
                      },
                      onMonthChanged: (month) {
                        setState(() {
                          currentDate = month;
                        });
                      },
                    ),

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
