import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';

typedef DateCallback = void Function(DateTime date);

class MoodCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<DateTime, Map<String, dynamic>> moodData;
  final DateCallback onDateSelected;
  final DateCallback onMonthChanged;

  const MoodCalendar({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.moodData,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  // Helper to format date as yyyy-MM-dd for DB keys
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _openEditDialog(BuildContext context, DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to edit mood entries.')),
      );
      return;
    }

    final db = DatabaseService();
    final key = _dateKey(date);
    final path = 'moods/${user.uid}/$key';

    // Capture navigator and scaffold messenger before any async gaps so we don't
    // use the BuildContext after an await (which can be invalid if the widget
    // tree changes). Also check context.mounted after async work.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Load existing entry if any
    final existing = await db.getMap(path);
    if (!context.mounted) return;

    final moodController = TextEditingController(
      text: existing?['mood']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: existing?['notes']?.toString() ?? '',
    );
    bool appointment = existing?['appointment'] == true;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isEditing = existing != null;
            return AlertDialog(
              title: Text(isEditing ? 'Edit Entry' : 'Save Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: moodController,
                      decoration: const InputDecoration(
                        labelText: 'Mood (emoji or text)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: appointment,
                          onChanged: (v) =>
                              setState(() => appointment = v ?? false),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Appointment / Event')),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Capture the dialog navigator before awaiting async work so
                    // we don't use the dialog BuildContext after an await.
                    final dialogNavigator = Navigator.of(ctx);
                    final mood = moodController.text.trim();
                    final notes = notesController.text.trim();
                    if (mood.isEmpty && !appointment && notes.isEmpty) {
                      // nothing to save
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a mood, notes, or mark an appointment.',
                          ),
                        ),
                      );
                      return;
                    }

                    final data = <String, dynamic>{
                      'mood': mood,
                      'notes': notes,
                      'appointment': appointment,
                      'updatedAt': DateTime.now().toIso8601String(),
                    };

                    try {
                      await db.set(path: path, data: data);
                      dialogNavigator.pop();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'Entry updated' : 'Entry saved',
                          ),
                        ),
                      );
                      // Let parent know the date was selected/changed so it can refresh data
                      onDateSelected(DateTime(date.year, date.month, date.day));
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('Failed to save entry: $e')),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Edit Entry' : 'Save Entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startCalendar = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday - 1),
    );

    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
                  onMonthChanged(
                    DateTime(currentMonth.year, currentMonth.month - 1),
                  );
                },
                icon: const Icon(Icons.chevron_left, size: 28),
              ),
              Text(
                "${_getMonthName(currentMonth.month)}'${currentMonth.year.toString().substring(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Allow navigating to the next month (including future months).
                  final nextMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                  onMonthChanged(nextMonth);
                },
                icon: const Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: Colors.black,
                ),
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

          // Calendar grid (6 weeks)
          ...List.generate(6, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final date = startCalendar.add(
                  Duration(days: weekIndex * 7 + dayIndex),
                );
                final isCurrentMonth = date.month == currentMonth.month;
                final isToday = _isSameDay(date, DateTime.now());
                final isSelected = _isSameDay(date, selectedDate);
                final isFuture = date.isAfter(DateTime.now());
                final mood =
                    moodData[DateTime(date.year, date.month, date.day)];
                final isAppointment =
                    mood != null &&
                    ((mood['appointment'] == true) ||
                        (mood['mood'] != null && mood['mood'] == '📅'));

                return Expanded(
                  child: GestureDetector(
                    // Single tap selects the date (no popup). Long-press opens the
                    // edit dialog for authenticated users.
                    onTap: isCurrentMonth && !isFuture
                        ? () {
                            onDateSelected(
                              DateTime(date.year, date.month, date.day),
                            );
                          }
                        : null,
                    onLongPress: isCurrentMonth && !isFuture
                        ? () {
                            _openEditDialog(
                              context,
                              DateTime(date.year, date.month, date.day),
                            );
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
                            ? (isAppointment
                                  ? Colors.orange.withValues(alpha: 0.25)
                                  : (mood != null
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.transparent))
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
                                  ? (isAppointment
                                        ? Colors.orange
                                        : Colors.black)
                                  : Colors.grey,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (mood != null && isCurrentMonth)
                            Text(
                              mood['mood'] ?? '',
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
}
