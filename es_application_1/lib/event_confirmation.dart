import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Some Test Done

class EventConfirmationPage extends StatelessWidget {
  final String postId;

  const EventConfirmationPage({super.key, required this.postId});

  // Function to handle updating participation status
  void updateParticipationStatus(BuildContext context, String userId, bool value) {
    // Retrieve user data
    Future<DocumentSnapshot> userDataFuture = FirebaseFirestore.instance.collection('users').doc(userId).get();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('User data not found'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String firstName = userData['firstName'] ?? '';
            String lastName = userData['lastName'] ?? '';
            String profilePictureURL = userData['profilePictureURL'] ?? '';

            return AlertDialog(
              title: const Text('Confirm Participation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureURL),
                    ),
                    title: Text('$firstName $lastName'),
                  ),
                  Text('Are you sure you want to register the presence as ${value ? 'On time' : 'Late'}?'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    // Update participation status in the database
                    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
                      'subscribed': FieldValue.arrayRemove([userId]),
                      'participated': FieldValue.arrayUnion([userId]),
                      'onTime': value,
                    });

                    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
                    var userData = await userDocRef.get();
                    if (userData.exists) {
                      Map<String, dynamic>? userDataMap = userData.data() as Map<String, dynamic>?; // Explicit cast

                      if (userDataMap != null) {
                        /// Add to the participated
                        List<String> participatedPosts = List<String>.from(userDataMap['participated'] ?? []);
                        participatedPosts.add(postId);

                        /// Remove from the subscribed
                        List<String> subscribedPosts = List<String>.from(userDataMap['subscribed'] ?? []);
                        subscribedPosts.remove(postId);

                        // Calculate points to add
                        int pointsToAdd = value ? 10 : 5;

                        // Update both 'participated' and 'points' fields
                        await userDocRef.set(
                          {
                            'participated': participatedPosts,
                            'subscribed': subscribedPosts,
                            'points': FieldValue.increment(pointsToAdd),
                          },
                          SetOptions(merge: true),
                        );
                      }
                    }

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Participation'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').doc(postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Post not found'));
          }

          var postData = snapshot.data!.data() as Map<String, dynamic>;
          Timestamp eventDate = postData['date'];
          String startTime = postData['startTime'];
          String endTime = postData['endTime'];
          List<String> subscribedUsers = List<String>.from(postData['subscribed'] ?? []);
          List<String> participatedUsers = List<String>.from(postData['participated'] ?? []);

          // Get current date and time
          DateTime now = DateTime.now();

          // Parse start time and end time strings
          DateTime activityStartTime = DateTime.parse('${eventDate.toDate().toString().substring(0, 10)} $startTime:00');
          DateTime activityEndTime = DateTime.parse('${eventDate.toDate().toString().substring(0, 10)} $endTime:00');

          // Check if current time is within activity start and end time
          bool isActivityOngoing = now.isAfter(activityStartTime) && now.isBefore(activityEndTime);

          if (isActivityOngoing) {

            if (subscribedUsers.isEmpty) {
              return const Center(child: Text('No more subscribed people'));
            }
            return ListView.builder(
              itemCount: subscribedUsers.length,
              itemBuilder: (context, index) {
                String userId = subscribedUsers[index];
                bool isParticipated = participatedUsers.contains(userId);
                bool isOnTime = postData['onTimeUsers'] != null && postData['onTimeUsers'].contains(userId);
                bool isLate = postData['lateUsers'] != null && postData['lateUsers'].contains(userId);

                return ListTile(
                  leading: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar();
                      }
                      if (!snapshot.hasData) {
                        return const CircleAvatar();
                      }
                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      String profilePictureURL = userData['profilePictureURL'] ?? '';
                      return CircleAvatar(
                        backgroundImage: NetworkImage(profilePictureURL),
                      );
                    },
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      if (!snapshot.hasData) {
                        return const Text('User not found');
                      }
                      var userData = snapshot.data!.data() as Map<String, dynamic>;
                      String firstName = userData['firstName'] ?? '';
                      String lastName = userData['lastName'] ?? '';
                      return Text('$firstName $lastName');
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: isParticipated && isOnTime,
                        onChanged: (value) {
                          if (value != null) {
                            // Call function to update participation status
                            updateParticipationStatus(context, userId, value);
                          }
                        },
                      ),
                      const Text('On time'),
                      const SizedBox(width: 10),
                      Checkbox(
                        value: isParticipated && isLate,
                        onChanged: (value) {
                          if (value != null) {
                            // Call function to update participation status
                            updateParticipationStatus(context, userId, !value); // Invert the value for 'Late'
                          }
                        },
                      ),
                      const Text('Late'),
                    ],
                  ),
                );
              },
            );

          } else if (now.isAfter(activityEndTime)) {
            // Activity already happened
            return const Center(child: Text('The activity already happened'));
          } else {
            // Activity hasn't started yet
            return const Center(child: Text('The activity hasn\'t started yet'));
          }
        },
      ),
    );
  }
}
