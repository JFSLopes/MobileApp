import 'package:es_application_1/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChangeAreasPage extends StatefulWidget {
  const ChangeAreasPage({super.key});

  @override
  _ChangeAreasPageState createState() => _ChangeAreasPageState();
}

class _ChangeAreasPageState extends State<ChangeAreasPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  DateTime? _selectedDate;
  final List<String> _selectedInterests = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      DocumentSnapshot categoriesDoc = await FirebaseFirestore.instance.collection('categories').doc('categories').get();
      List<String> categories = List<String>.from(categoriesDoc.get('name'));
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> submitPersonalData(BuildContext context) async {
    try {
      if (_firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _selectedDate == null ||
          _selectedInterests.isEmpty) {
        throw Exception('Please fill in all required fields.');
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'birthday': _selectedDate,
          'interests': _selectedInterests,
          'points': userData.get('points'),
          'location' : userData.get('location'),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal data submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );

      } else {
        throw Exception('User not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to submit personal data. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error submitting personal data: $e');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Enter Personal Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name *'),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name *'),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Future.microtask(() {
                  selectDate(context);
                });
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: _selectedDate != null ? _selectedDate.toString().substring(0, 10) : ''),
                  decoration: const InputDecoration(labelText: 'Birthday *'),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Areas of Interest *',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 8.0,
              children: _categories.map((category) => _buildInterestChip(category)).toList(),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => submitPersonalData(context),
                  child: const Text('Submit'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen())
                    );
                  },
                  child: const Text('Cancel',
                    style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    final isSelected = _selectedInterests.contains(interest);
    return FilterChip(
      label: Text(interest),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(interest);
          } else {
            _selectedInterests.remove(interest);
          }
        });
      },
    );
  }
}
