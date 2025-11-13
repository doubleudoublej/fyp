import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/points_badge.dart';
import '../services/points_service.dart';
import '../services/auth_service.dart';
import 'mood_tracker_screen.dart';
import '../widgets/mood_calendar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DateTime currentDate;
  late DateTime selectedDate;
  // keep a small mood/marker map; profile uses appointment marker optionally
  Map<DateTime, Map<String, dynamic>> moodData = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentDate = DateTime(now.year, now.month);
    selectedDate = DateTime(now.year, now.month, now.day);
    // Example: if you want to mark an appointment day in the calendar, add it here
    // Example appointment so the calendar shows an orange marker.
    // Add a fixed appointment on December 03, 2025 to be shown in Next Appointment
    moodData[DateTime(2025, 12, 3)] = {
      'mood': '📅',
      'appointment': true,
      'notes': 'Video call with Dr. Tan',
      'time': '2:30 PM - 3:30 PM',
      'title': 'Dr. Peter Tan',
    };
  }

  // Returns the next appointment DateTime and its data map, or null if none
  MapEntry<DateTime, Map<String, dynamic>>? _getNextAppointment() {
    final now = DateTime.now();
    final futureAppointments = moodData.entries.where((e) {
      final d = e.key;
      final map = e.value;
      final isAppt = map['appointment'] == true || map['mood'] == '📅';
      return isAppt &&
          DateTime(
            d.year,
            d.month,
            d.day,
          ).isAfter(DateTime(now.year, now.month, now.day - 1));
    }).toList();

    if (futureAppointments.isEmpty) return null;

    futureAppointments.sort((a, b) => a.key.compareTo(b.key));
    return futureAppointments.first;
  }

  String _formatDate(DateTime d) {
    final weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final wd = weekdays[d.weekday % 7];
    final m = months[d.month];
    final day = d.day.toString().padLeft(2, '0');
    final year = d.year;
    return '$wd, $m $day, $year';
  }

  @override
  Widget build(BuildContext context) {
    // Today's date is available via state (selectedDate/currentDate) when needed
    return Scaffold(
      backgroundColor: const Color(0xFF7ED321), // Same green background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Main content area - Scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // User Profile Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Picture
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7ED321),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // User Name
                            const Text(
                              'Jay Wong',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // User Details
                            const Text(
                              'Age: 28 • Joined: March 2024',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Points Section
                            // Show live points from Realtime Database
                            StreamBuilder<int>(
                              stream: (() {
                                final user = AuthService().currentUser;
                                if (user == null) {
                                  return const Stream<int>.empty();
                                }
                                return PointsService().pointsStream(user.uid);
                              })(),
                              builder: (context, snapshot) {
                                final pts = snapshot.data ?? 0;
                                return PointsBadge(points: pts);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Personal Information Section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF7ED321),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Personal Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Info Items
                            _buildInfoItem(
                              'Username',
                              'doubleudoublej',
                              Icons.person_outline,
                            ),
                            _buildInfoItem(
                              'Email',
                              'jay.wong@email.com',
                              Icons.email,
                            ),
                            _buildInfoItem(
                              'Phone',
                              '+65 0000 0000',
                              Icons.phone,
                            ),
                            _buildInfoItem(
                              'Emergency Contact',
                              'James (Brother)',
                              Icons.contact_emergency,
                            ),
                            _buildInfoItem(
                              'Therapist',
                              'Dr. Peter Tan',
                              Icons.psychology,
                            ),
                          ],
                        ),
                      ),

                      // Mood Tracker Section
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MoodTrackerScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF7ED321),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF7ED321),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.mood,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mood Tracker',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Track your daily emotional wellbeing',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF7ED321),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Next Schedule Section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF7ED321),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Next Appointment',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Builder(
                              builder: (context) {
                                final entry = _getNextAppointment();
                                if (entry == null) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF7ED321,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'No upcoming appointments',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  );
                                }

                                final date = entry.key;
                                final data = entry.value;
                                final title = data['title'] ?? 'Appointment';
                                final time = data['time'] ?? '';
                                final notes = data['notes'] ?? '';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF7ED321,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDate(date),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      if (time.isNotEmpty)
                                        Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      if (notes.isNotEmpty)
                                        const SizedBox(height: 8),
                                      if (notes.isNotEmpty)
                                        Text(
                                          notes,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF7ED321),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Calendar Widget (now extracted)
                      MoodCalendar(
                        currentMonth: currentDate,
                        selectedDate: selectedDate,
                        moodData: moodData,
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        onMonthChanged: (month) {
                          setState(() {
                            currentDate = month;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem(const Color(0xFF7ED321), 'Today'),
                          const SizedBox(width: 16),
                          _buildLegendItem(Colors.orange, 'Appointment'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Custom Bottom Navigation (index 3 = Profile)
            const CustomBottomNavigationBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF7ED321)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
