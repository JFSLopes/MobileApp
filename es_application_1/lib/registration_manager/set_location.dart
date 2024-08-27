import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_page.dart';

// Some Tests Done

class AskDistance extends StatefulWidget {
  const AskDistance({super.key});

  @override
  _AskDistanceState createState() => _AskDistanceState();
}

class _AskDistanceState extends State<AskDistance> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _distanceController = TextEditingController();
  double _sliderValue = 5;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _currentLocation;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _distanceController.text = _sliderValue.toStringAsFixed(0);
    _checkPermissionAndGetCurrentLocation();
  }

  Future<void> _checkPermissionAndGetCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        // Missing logic if user denies
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Missing logic when user denied forever
      return;
    }
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = position;
        _moveToCurrentLocation();
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _moveToCurrentLocation() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
            zoom: 14,
          ),
        ),
      );
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers.clear();
      _markers.add(Marker(markerId: const MarkerId('selectedLocation'), position: position));
    });
  }

  void _onUseCurrentLocation() {
    setState(() {
      _markers.clear(); // Clear existing markers
      _selectedLocation = null; // Reset selected location

      // Get current location
      _checkPermissionAndGetCurrentLocation().then((_) {
        // Set marker at the current location
        if (_currentLocation != null) {
          _markers.add(Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          ));
        }
      });
    });
  }

  void _saveUserData() async {
    if (_selectedLocation != null || _markers.isNotEmpty) {
      LatLng? location;
      if (_selectedLocation != null) {
        location = _selectedLocation;
      } else if (_markers.isNotEmpty) {
        location = _markers.first.position;
      }

      if (location != null) {
        // Retrieve user information
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Store data in Firestore
          String userId = user.uid;
          double distance = _sliderValue;
          GeoPoint userLocation = GeoPoint(location.latitude, location.longitude);

          try {
            DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
            userRef.update({
              'distance': distance,
              'location': userLocation,
            });

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (Route<dynamic> route) => false,
            );
          } catch (e) {
            print('Error storing data: $e');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to store data. Please try again.'),
              backgroundColor: Colors.red,
            ));
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a location on the map.'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a location on the map.'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Ask Distance'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Choose the distance',
            style: TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.green[800],
                    inactiveTrackColor: Colors.green[700],
                    thumbColor: Colors.green[200],
                  ),
                  child: Slider(
                    value: _sliderValue,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    label: '${_sliderValue.round()} km',
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                        _distanceController.text = _sliderValue.toStringAsFixed(0);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_sliderValue.round()} km', style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Select the location',
            style: TextStyle(fontSize: 20, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(37.7749, -122.4194),
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    setState(() {
                      _mapController = controller;
                    });
                  },
                  onTap: _onMapTap,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: ElevatedButton(
                    onPressed: _onUseCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Use current location'),
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: _saveUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
