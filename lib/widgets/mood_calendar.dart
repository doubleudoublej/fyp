import 'package:flutter/material.dart';

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
                    onTap: isCurrentMonth && !isFuture
                        ? () {
                            onDateSelected(
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
