import 'package:es_application_1/ranking_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'welcome_screen.dart';
import 'favorites_page.dart';
import 'registration_manager/user_info.dart';
import 'package:intl/intl.dart';
import 'sustainability_tips.dart';
import 'create_post/create_post.dart';
import 'get_activities/get_activities.dart';
import 'post_info.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final FirebaseFirestore _firestore;
  late final User? _currentUser;
  late final ActivityManager _activityManager;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _currentUser = FirebaseAuth.instance.currentUser;
    _activityManager = ActivityManager(_firestore, _currentUser);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserInfoAndShowTip(context));
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    try {
      final userData = await FirebaseFirestore.instance.collection('users').doc(_currentUser?.uid).get();
      setState(() {
        _userPoints = userData.get('points') ?? 0; // Get user points or default to 0
      });
    } catch (e) {
      print('Error loading user points: $e');
    }
  }

  Future<void> _checkUserInfoAndShowTip(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!userData.exists ||
          !(userData.data()!.containsKey('firstName') &&
              userData.data()!.containsKey('birthday') &&
              userData.data()!.containsKey('interests') &&
              userData.data()!.containsKey('location'))) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PersonalDataPage()),
        );
      } else {
        _maybeShowSustainabilityTip();
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  void _maybeShowSustainabilityTip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool hasSeenTip = prefs.getBool('hasSeenTip_$today') ?? false;

    if (!hasSeenTip) {
      String dailyTip = SustainabilityTips.getDailyTip();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Daily Sustainability Tip'),
            content: Text(dailyTip),
            actions: <Widget>[
              TextButton(
                child: const Text('Got it!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  prefs.setBool('hasSeenTip_$today', true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildActivitiesList(List<DocumentSnapshot>? activities) {
    if (activities == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (activities.isEmpty) {
      return const Center(child: Text('No activities found.'));
    } else {
      return ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          final uid = activity['user'];

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final userName = userSnapshot.data!['firstName'] + " " + userSnapshot.data!['lastName'];
              String? userProfilePhoto;
              /// Phot URL might not exist
              try {
                userProfilePhoto = userSnapshot.data!["profilePictureURL"] as String?;
              } catch (e) {
                userProfilePhoto = null;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityDetailPage(activityId: activity.id),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: userProfilePhoto != null ? Colors.transparent : Colors.green,
                                  image: userProfilePhoto != null
                                      ? DecorationImage(
                                    image: NetworkImage(userProfilePhoto),
                                    fit: BoxFit.cover,
                                  )
                                      : null,
                                ),
                                child: userProfilePhoto == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              activity['activityName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity['description'],
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Categories: ${activity['categories'].join(', ')}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoMobilize'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Row(
              children: <Widget>[
                Text('Your Points: $_userPoints'),
                const SizedBox(width: 5),
                const Icon(Icons.star, color: Colors.yellow),
              ],
            ),
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _activityManager.getActivities(),
        builder: (context, snapshot) {
          return _buildActivitiesList(snapshot.data);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.green,
                    size: 30.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RankingPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.leaderboard,
                    color: Colors.green,
                    size: 30.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.green,
                    size: 30.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
