import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Some tests done

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  CreatePostScreenState createState() => CreatePostScreenState();

  static CreatePostScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<CreatePostScreenState>();
}

class CreatePostScreenState extends State<CreatePostScreen> {
  LatLng? _selectedLocation;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<String> _selectedCategories = [];
  final user = FirebaseAuth.instance.currentUser;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.Hm().format(dateTime);
  }

  Future<void> loadCategories() async {
    try {
      DocumentSnapshot categoriesDoc =
      await FirebaseFirestore.instance.collection('categories').doc('categories').get();
      List<String> categories = List<String>.from(categoriesDoc.get('name'));
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  void _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime firstSelectableDate = currentDate.add(const Duration(days: 3));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate.isBefore(firstSelectableDate) ? firstSelectableDate : currentDate,
      firstDate: firstSelectableDate, // At least 3 days from today
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  Future<void> selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _endTime) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  void submitPost() async {
    if (_selectedDate != null &&
        _activityNameController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedLocation != null &&
        _selectedCategories.isNotEmpty &&
        _startTime != null &&
        _endTime != null &&
        _endTime!.hour > _startTime!.hour) {
      try {

        Map<String, dynamic> postData = {
          'activityName': _activityNameController.text,
          'description': _descriptionController.text,
          'date': _selectedDate!,
          'startTime': formatTimeOfDay(_startTime!), // Convert TimeOfDay to string
          'endTime': formatTimeOfDay(_endTime!),
          'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
          'categories': _selectedCategories,
          'user': user?.uid
        };

        await FirebaseFirestore.instance.collection('posts').add(postData);

        // Update user points
        await updateUserPoints(20);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post submitted successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error submitting post: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error submitting post'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Show an error message indicating that all fields are required or the time selection is invalid
      String errorMessage = 'All fields are required.';
      if (_endTime != null && _startTime != null && _endTime!.hour <= _startTime!.hour) {
        errorMessage = 'End time must be greater than start time.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> updateUserPoints(int pointsToAdd) async {
    try {
      // Update user points
      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set(
        {'points': FieldValue.increment(pointsToAdd)},
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating user points: $e');
    }
  }

  void updateLocation(LatLng newLocation) {
    setState(() {
      _selectedLocation = newLocation;
      _locationController.text = '${newLocation.latitude}, ${newLocation.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _activityNameController,
                decoration: const InputDecoration(
                  labelText: 'Activity Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                onTap: () {
                  _selectDate(context);
                },
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '',
                ),
                decoration: const InputDecoration(
                  labelText: 'When will it happen *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onTap: () {
                        selectStartTime(context);
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _startTime != null ? _startTime!.format(context) : '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Start Time *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      onTap: () {
                        selectEndTime(context);
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _endTime != null ? _endTime!.format(context) : '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'End Time *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationPicker(
                          onLocationSelected: updateLocation,
                        ),
                      ),
                    );
                    if (selectedLocation != null && selectedLocation is LatLng) {
                      updateLocation(selectedLocation);
                    }
                  },
                  child: const Text('Choose Location'),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Categories *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              Wrap(
                spacing: 8.0,
                children: _categories.map((category) => _buildCategoryChip(category)).toList(),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: submitPost,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategories.contains(category);
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _selectedCategories.add(category);
          } else {
            _selectedCategories.remove(category);
          }
        });
      },
    );
  }
}

