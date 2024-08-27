import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:es_application_1/post_info.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('ActivityDetailPage', () {
    late ActivityDetailPage activityDetailPage;
    const String mockActivityId = 'mockActivityId';

    setUp(() {
      activityDetailPage = const ActivityDetailPage(activityId: mockActivityId);
    });

    group('formatCoordinate', () {
      test('should format positive latitude coordinate', () {
        const double latitude = 45.6789;
        final String formattedCoordinate = activityDetailPage.getState().formatCoordinate(latitude);
        expect(formattedCoordinate, '45.6789000');
      });
    });
  });

  group('ActivityDetailPage Widget Tests', () {
    testWidgets('ActivityDetailPage UI components', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ActivityDetailPage(activityId: 'mockActivityId')));
      expect(find.text('Activity Details'), findsOneWidget);
    });
  });
}

// Mock classes
class MockUser extends Mock implements User {}
