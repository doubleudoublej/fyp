// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Mental Health App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MentalHealthApp());

    // Verify that our splash screen shows up initially
    expect(find.text('Mental Health Companion'), findsOneWidget);
    expect(find.text('Swimming towards wellness'), findsOneWidget);

    // Verify dolphin emoji is present
    expect(find.text('🐬'), findsOneWidget);
  });

  testWidgets('Home screen buttons work correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MentalHealthApp());

    // Wait for splash screen to complete and navigate to home screen
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that home screen elements are present
    expect(find.text('Welcome to your wellness journey'), findsOneWidget);
    expect(find.text('Button A'), findsOneWidget);
    expect(find.text('Button B'), findsOneWidget);
    expect(find.text('Button C'), findsOneWidget);
    expect(find.text('Button D'), findsOneWidget);

    // Test that Button A can be tapped
    await tester.tap(find.text('Button A'));
    await tester.pump();

    // Verify that snackbar appears when button is pressed
    expect(find.text('Button A pressed'), findsOneWidget);
  });
}
