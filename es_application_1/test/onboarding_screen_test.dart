import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:es_application_1/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingScreen Widget Tests', () {
    testWidgets('OnboardingScreen shows initial page and navigates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

      // Verify the initial page
      expect(find.text('Love Your Planet'), findsOneWidget);
      expect(find.text('Recycle & Reuse'), findsNothing);
      expect(find.text('Green Commuting'), findsNothing);

      // Tap the next button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the second page
      expect(find.text('Recycle & Reuse'), findsOneWidget);
      expect(find.text('Love Your Planet'), findsNothing);
      expect(find.text('Green Commuting'), findsNothing);

      // Tap the next button again
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the third page
      expect(find.text('Green Commuting'), findsOneWidget);
      expect(find.text('Love Your Planet'), findsNothing);
      expect(find.text('Recycle & Reuse'), findsNothing);

      // Tap the Get Started button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    });
  });

  group('OnboardingScreen Unit Tests', () {
    test('setOnboardingComplete sets seenOnboarding to true', () async {
      // Initialize mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create an instance of OnboardingScreen state
      final onboardingScreenState = OnboardingScreen().createState();

      // Call setOnboardingComplete method
      await onboardingScreenState.setOnboardingComplete();

      // Get the SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Verify that seenOnboarding is set to true
      expect(prefs.getBool('seenOnboarding'), isTrue);
    });
  });
}
