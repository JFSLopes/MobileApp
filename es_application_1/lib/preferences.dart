import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:es_application_1/profile_page.dart';
import 'package:es_application_1/ranking_page.dart';
import 'package:flutter/material.dart';
import 'create_post/create_post.dart';
import 'favorites_page.dart';
import 'main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final String? initialImageUrl;

  const EditProfilePage({super.key, this.initialImageUrl});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}



class _EditProfilePageState extends State<EditProfilePage> {
  bool _receiveEmailNotificationsLocal = true;
  bool _systemNotificationsLocal = true;
  bool _onlyNearLocal = true;
  bool _lastTimeOnLocal = true;
  bool _profilePictureLocal = true;
  bool _favouritesLocal = true;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _receiveEmailNotificationsLocal =
          prefs.getBool('receiveEmailNotifications') ?? true;
      _systemNotificationsLocal = prefs.getBool('systemNotifications') ?? true;
      _onlyNearLocal = prefs.getBool('onlyNear') ?? true;
      _lastTimeOnLocal = prefs.getBool('lastTimeOn') ?? true;
      _profilePictureLocal = prefs.getBool('profilePhoto') ?? true;
      _favouritesLocal = prefs.getBool('favourites') ?? true;
    });
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('receiveEmailNotifications', _receiveEmailNotificationsLocal);
    prefs.setBool('systemNotifications', _systemNotificationsLocal);
    prefs.setBool('onlyNear', _onlyNearLocal);
    prefs.setBool('lastTimeOn', _lastTimeOnLocal);
    prefs.setBool('profilePhoto', _profilePictureLocal);
    prefs.setBool('favourites', _favouritesLocal);
  }

  Future<void> _updateProfilePictureURL(String imageUrl) async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profilePictureURL': imageUrl,
      });

      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      print('Error updating profile picture URL: $e');
    }
  }

  Future<void> _selectImageURLFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
        String fileName = '$uid.jpg';
        File imageFile = File(pickedFile.path);
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('profile_pic/$fileName');
        await ref.putFile(imageFile);

        String downloadURL = await ref.getDownloadURL();

        await _updateProfilePictureURL(downloadURL);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _selectImageURLFromGallery,
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: _imageUrl != null ? null : Colors.green[200],
                        backgroundImage: _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: _selectImageURLFromGallery,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Notification Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Receive Email Notifications'),
                value: _receiveEmailNotificationsLocal,
                onChanged: (value) {
                  setState(() {
                    _receiveEmailNotificationsLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              SwitchListTile(
                title: const Text('System Notifications'),
                value: _systemNotificationsLocal,
                onChanged: (value) {
                  setState(() {
                    _systemNotificationsLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              SwitchListTile(
                title: const Text('Only Near Activities'),
                value: _onlyNearLocal,
                onChanged: (value) {
                  setState(() {
                    _onlyNearLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              SwitchListTile(
                title: const Text('Last Time On'),
                value: _lastTimeOnLocal,
                onChanged: (value) {
                  setState(() {
                    _lastTimeOnLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 15),
              const Text(
                'Privacy Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Profile Picture'),
                value: _profilePictureLocal,
                onChanged: (value) {
                  setState(() {
                    _profilePictureLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              SwitchListTile(
                title: const Text('My Favourites'),
                value: _favouritesLocal,
                onChanged: (value) {
                  setState(() {
                    _favouritesLocal = value;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    saveSettings();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white),
                  child: const Text('Save Changes'),
                ),
              ),
              Center(
                child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen())
                  );
                },
                  child: const Text('Cancel Changes',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
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