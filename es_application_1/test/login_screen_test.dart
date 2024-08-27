import 'package:es_application_1/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Tests', () {

    testWidgets('Email and password fields exist', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.byType(TextFormField), findsNWidgets(2)); // Deve encontrar dois TextFormFields.
    });

    testWidgets('Login button starts login process', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    });
  });
}