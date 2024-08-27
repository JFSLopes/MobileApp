import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:es_application_1/welcome_screen.dart';
import 'package:es_application_1/authentication/register_screen.dart';
import 'package:es_application_1/authentication/login_screen.dart';

void main() {
  testWidgets('Widget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    expect(find.text('EcoMobilize'), findsOneWidget);
    expect(find.text('Making the world a greener place, one step at a time.'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('Tap on "Create Account" button navigates to RegisterScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('Tap on "I already have an account" button navigates to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
