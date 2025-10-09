import 'package:flutter/material.dart';
import '../services/api_client.dart';

class HealthTestWidget extends StatefulWidget {
  const HealthTestWidget({super.key});

  @override
  State<HealthTestWidget> createState() => _HealthTestWidgetState();
}

class _HealthTestWidgetState extends State<HealthTestWidget> {
  String _result = 'Not tested';

  Future<void> _runTest() async {
    setState(() => _result = 'Calling...');
    final api = ApiClient();
    try {
      final resp = await api.get('/api/health');
      setState(() => _result = 'OK: ${resp.data}');
    } catch (e) {
      setState(() => _result = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _runTest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7ED321),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Test /api/health'),
        ),
        const SizedBox(height: 8),
        Text(_result, textAlign: TextAlign.center),
      ],
    );
  }
}
