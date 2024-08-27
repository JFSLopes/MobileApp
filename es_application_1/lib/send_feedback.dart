import 'package:es_application_1/profile_page.dart';
import 'package:es_application_1/ranking_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_post/create_post.dart';
import 'favorites_page.dart';
import 'main_page.dart';
import 'dart:async';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _sendFeedback() async {
    final String feedback = _feedbackController.text.trim();
    if (feedback.isNotEmpty) {
      try {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          final reviewsCollection = FirebaseFirestore.instance.collection('reviews');

          await reviewsCollection.doc(user.uid).set({
            'feedback': feedback,
            'timestamp': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Your feedback has been sent successfully!'),
            backgroundColor: Colors.green[800],
          ));
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send feedback. Please try again.'),
          backgroundColor: Colors.red,
        ));
        print('Error sending feedback: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter feedback before sending.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.green[800],
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 2,
      ),
      body: GestureDetector(
        onTap: () => _feedbackController.clear(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Please write here any bugs or issues that you found.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontFamily: 'Outfit',
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _feedbackController,
                  autofocus: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    labelText: 'Feedback',
                    hintText: 'Write your feedback here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: const Icon(Icons.feedback, color: Colors.green),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                const SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: _sendFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 20.0),
                    textStyle: const TextStyle(fontSize: 20.0, fontFamily: 'Readex Pro'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Send Feedback'),
                ),
              ],
            ),
          ),
        ),
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
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.home,
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
          ],
        ),
      ),
    );
  }
}
