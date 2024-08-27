import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

/// Tests Done

class ActivityManager {
  final FirebaseFirestore _firestore;
  final User? _currentUser;

  List<String> interests = [];
  double distance = 0;
  GeoPoint userLocation = const GeoPoint(0, 0);

  ActivityManager(this._firestore, this._currentUser) {
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser.uid).get();
        interests = List<String>.from(userDoc.get('interests'));
        distance = userDoc.get('distance') * 1000 ?? 0;
        userLocation = userDoc.get('location') ?? const GeoPoint(0, 0);
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<List<DocumentSnapshot>> getActivities() async {
    try {
      List<DocumentSnapshot> activities = [];
      QuerySnapshot postSnapshot = await _firestore.collection('posts').get();

      DateTime currentDate = DateTime.now();
      DateTime eightHoursAgo = currentDate.subtract(const Duration(hours: 8));

      for (DocumentSnapshot postDoc in postSnapshot.docs) {
        List<String> postCategories = List<String>.from(postDoc.get('categories'));
        String creator = postDoc.get('user');
        if (_currentUser?.uid != creator) { /// Does not show post from the user logged in
          if (categoriesMatchInterests(postCategories, interests)) {
            /// Check if the activity hasn'i occur
            DateTime activityDate = postDoc['date'].toDate();
            String startTime = postDoc['startTime'];
            DateTime combinedDateTime = DateTime(activityDate.year, activityDate.month, activityDate.day,
              int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));

            if (combinedDateTime.isAfter(eightHoursAgo)) {
              double activityDistance = calculateDistance(
                userLocation.latitude,
                userLocation.longitude,
                postDoc['location'].latitude,
                postDoc['location'].longitude,
              );

              if (activityDistance <= distance * 1000) { /// Check distance
                activities.add(postDoc);
              }
            }
          }
        }
      }

      return activities;
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }


  bool categoriesMatchInterests(List<String> activityCategories, List<String> userInterests) {
    for (String category in activityCategories) {
      if (userInterests.contains(category)) {
        return true;
      }
    }
    return false;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const int earthRadius = 6371; // Earth radius in kilometers
  double latDiff = degreesToRadians(lat2 - lat1);
  double lonDiff = degreesToRadians(lon2 - lon1);
  double a = sin(latDiff / 2) * sin(latDiff / 2) +
      cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) *
      sin(lonDiff / 2) * sin(lonDiff / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}


  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
