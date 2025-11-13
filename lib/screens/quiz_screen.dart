import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'home_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();

  final List<Map<String, String>> _questions = const [
    {'text': 'I found it hard to wind down', 'sub': 's'},
    {'text': 'I was aware of dryness of my mouth', 'sub': 'a'},
    {
      'text': 'I couldn\'t seem to experience any positive feeling at all',
      'sub': 'd',
    },
    {'text': 'I experienced breathing difficulty', 'sub': 'a'},
    {
      'text': 'I found it difficult to work up the initiative to do things',
      'sub': 'd',
    },
    {'text': 'I tended to over-react to situations', 'sub': 's'},
    {'text': 'I experienced trembling (e.g., in the hands)', 'sub': 'a'},
    {'text': 'I felt that I was using a lot of nervous energy', 'sub': 's'},
    {
      'text': 'I was worried about situations in which I might panic',
      'sub': 'a',
    },
    {'text': 'I felt that I had nothing to look forward to', 'sub': 'd'},
    {'text': 'I found myself getting agitated', 'sub': 's'},
    {'text': 'I found it difficult to relax', 'sub': 's'},
    {'text': 'I felt down-hearted and blue', 'sub': 'd'},
    {
      'text':
          'I was intolerant of anything that kept me from getting on with what I was doing',
      'sub': 's',
    },
    {'text': 'I felt I was close to panic', 'sub': 'a'},
    {'text': 'I was unable to become enthusiastic about anything', 'sub': 'd'},
    {'text': 'I felt I wasn\'t worth much as a person', 'sub': 'd'},
    {'text': 'I felt that I was rather touchy', 'sub': 's'},
    {
      'text':
          'I was aware of the action of my heart in the absence of physical exertion',
      'sub': 'a',
    },
    {'text': 'I felt scared without any good reason', 'sub': 'a'},
    {'text': 'I felt that life was meaningless', 'sub': 'd'},
  ];

  final List<int> _answers = List<int>.filled(21, 0);
  bool _submitting = false;

  String _classify(String sub, int score) {
    if (sub == 'd') {
      if (score >= 28) return 'Extremely Severe';
      if (score >= 21) return 'Severe';
      if (score >= 14) return 'Moderate';
      if (score >= 10) return 'Mild';
      return 'Normal';
    } else if (sub == 'a') {
      if (score >= 20) return 'Extremely Severe';
      if (score >= 15) return 'Severe';
      if (score >= 10) return 'Moderate';
      if (score >= 8) return 'Mild';
      return 'Normal';
    } else {
      if (score >= 34) return 'Extremely Severe';
      if (score >= 26) return 'Severe';
      if (score >= 19) return 'Moderate';
      if (score >= 15) return 'Mild';
      return 'Normal';
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // Capture messenger early to avoid using `context` after async gaps.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please sign in to submit the quiz.')),
        );
        return;
      }

      int rawD = 0, rawA = 0, rawS = 0;
      for (int i = 0; i < _questions.length; i++) {
        final val = _answers[i];
        final sub = _questions[i]['sub'];
        if (sub == 'd') rawD += val;
        if (sub == 'a') rawA += val;
        if (sub == 's') rawS += val;
      }

      final scoreD = rawD * 2;
      final scoreA = rawA * 2;
      final scoreS = rawS * 2;

      final catD = _classify('d', scoreD);
      final catA = _classify('a', scoreA);
      final catS = _classify('s', scoreS);

      // Use a filesystem-safe key for the database path (no '.' '#' '$' '[' ']').
      // ISO strings contain '.' which is disallowed as a RTDB key, so store
      // the human-readable ISO timestamp in the data but use milliseconds
      // since epoch as the path segment.
      final nowIso = DateTime.now().toIso8601String();
      final key = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
      final path = 'assessments/${user.uid}/$key';

      final answersMap = <String, dynamic>{};
      for (int i = 0; i < _answers.length; i++) {
        answersMap['q${i + 1}'] = _answers[i];
      }

      final data = {
        'depression_score': scoreD,
        'depression_category': catD,
        'anxiety_score': scoreA,
        'anxiety_category': catA,
        'stress_score': scoreS,
        'stress_category': catS,
        'answers': answersMap,
        'timestamp': nowIso,
      };

      await _db.set(path: path, data: data);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Assessment Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Depression: $scoreD ($catD)'),
              Text('Anxiety: $scoreA ($catA)'),
              Text('Stress: $scoreS ($catS)'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );

      // After showing results, navigate to Home and replace this screen.
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      // Use captured messenger to avoid BuildContext across async gaps.
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to submit quiz: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DASS-21 Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final q = _questions[index]['text']!;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q${index + 1}. $q',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(4, (opt) {
                              return ChoiceChip(
                                label: Text('$opt'),
                                selected: _answers[index] == opt,
                                onSelected: (sel) {
                                  setState(() => _answers[index] = opt);
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: Text(
                  _submitting ? 'Submitting...' : 'Submit Assessment',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
