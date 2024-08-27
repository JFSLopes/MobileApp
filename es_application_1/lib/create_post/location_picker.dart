import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Some tests Done

class LocationPicker extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;

  const LocationPicker({super.key, this.onLocationSelected});

  @override
  LocationPickerState createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }
  
  void getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        addMarker(LatLng(position.latitude, position.longitude));
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
        ),
      );
    });
  }

  void moveToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14,
          ),
        ),
      );
      addMarker(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
    }
  }

  void saveLocation() {
    if (widget.onLocationSelected != null && _markers.isNotEmpty) {
      widget.onLocationSelected!(_markers.first.position);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _currentPosition != null
                      ? CameraPosition(
                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          zoom: 14,
                        )
                      : const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 14,
                        ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: addMarker,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: ElevatedButton(
                    onPressed: moveToCurrentLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: saveLocation,
            child: const Text('Save Location'),
          ),
        ],
      ),
    );
  }
}
