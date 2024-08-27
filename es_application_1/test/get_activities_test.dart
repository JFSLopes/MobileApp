import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:es_application_1/get_activities/get_activities.dart';



void main() {
  group('ActivityManager', () {
    test('should return true if any category matches interests', () async {
      // Arrange
      final firestore = FakeFirebaseFirestore();
      final manager = ActivityManager(firestore, null);
      await firestore.collection('users').add({
        'interests': ['Music', 'Movies'],
      });

      // Act
      bool result = manager.categoriesMatchInterests(['Sports', 'Music'], ['Music', 'Movies']);

      // Assert
      expect(result, true);
    });

    test('should return false if no category matches interests', () async {
      // Arrange
      final firestore = FakeFirebaseFirestore();
      final manager = ActivityManager(firestore, null);
      await firestore.collection('users').add({
        'interests': ['Music', 'Movies'],
      });

      // Act
      bool result = manager.categoriesMatchInterests(['Sports', 'Outdoors'], ['Music', 'Movies']);

      // Assert
      expect(result, false);
    });

    test('should calculate distance between two points accurately', () {
      // Arrange
      final firestore = FakeFirebaseFirestore();
      final manager = ActivityManager(firestore, null);
      double userLat = 52.520008;
      double userLon = 13.404954;
      double activityLat = 48.856613;
      double activityLon = 2.352222;

      // Act
      double distance = manager.calculateDistance(userLat, userLon, activityLat, activityLon);

      // Assert
      expect(distance, closeTo(879.69 , 5)); // Paris to Berlin distance in kilometers
    });

    test('should convert degrees to radians correctly', () {
      // Arrange
      final firestore = FakeFirebaseFirestore();
      final manager = ActivityManager(firestore, null);
      double degrees = 90;

      // Act
      double radians = manager.degreesToRadians(degrees);

      // Assert
      expect(radians, closeTo(1.5708, 0.0001)); // Expected value of pi/2
    });
  });
}
