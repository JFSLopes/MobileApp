import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'favorites_page.dart';
import 'create_post/create_post.dart';
import 'profile_page.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  Future<List<QueryDocumentSnapshot>> fetchRankedUsers() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('points', descending: true)
        .get();
    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: fetchRankedUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return const Text("No data found!");
          }
          var currentUserRank = 1;
          var currentUserUid = FirebaseAuth.instance.currentUser?.uid;

          List<Widget> rankedUsers = snapshot.data!.asMap().entries.map((entry) {
            int rank = entry.key + 1;
            Map<String, dynamic> user = entry.value.data() as Map<String, dynamic>;
            bool isCurrentUser = entry.value.id == currentUserUid;

            if (isCurrentUser) currentUserRank = rank;

            return ListTile(
              leading: CircleAvatar(
                child: Text(rank.toString()),
              ),
              title: Text('${user['firstName']} ${user['lastName']}'),
              subtitle: Text('Points: ${user['points']}'),
              tileColor: isCurrentUser ? Colors.lightGreen[200] : null,
            );
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your current ranking is: #$currentUserRank',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              Expanded(
                child: ListView(
                  children: rankedUsers,
                ),
              ),
            ],
          );
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
