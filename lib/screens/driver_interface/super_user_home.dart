import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kary_win/screens/driver_interface/profile.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/data.dart'; // Import your local data
import 'package:firebase_database/firebase_database.dart';

class DriverRouteScreen extends StatefulWidget {
  const DriverRouteScreen({super.key});

  @override
  _DriverRouteScreenState createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends State<DriverRouteScreen> {
  List<Polyline> polylines = [];
  List<Marker> markers = [];
  bool _formVisible = true;
  String? selectedRegion;
  String? selectedBus;
  LatLng? fetchedPointPosition;
  final MapController _mapController = MapController();
  bool hasAlert = false;
  StreamSubscription<DatabaseEvent>? alertSubscription;

  @override
  void initState() {
    super.initState();
    fetchBusStations();
    selectedBus = '';
    selectedRegion = '';

    // Set up a listener for real-time database updates
    locationStream(selectedBus!).listen((newPoint) {
      print('New point received: $newPoint');
      setState(() {
        fetchedPointPosition = newPoint;
      });
    });
  }

  @override
  void dispose() {
    alertSubscription?.cancel();
    super.dispose();
  }

  Stream<LatLng> locationStream(String routeId) {
    final databaseReference =
        FirebaseDatabase.instance.ref('Locations/$routeId');
    return databaseReference.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return LatLng(data['Latitude'], data['Longitude']);
    });
  }

  Stream<List<String>> fetchRegions() {
    return FirebaseFirestore.instance
        .collection('bus')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<List<String>> fetchSubcollections(String region) async {
    List<String> subcollectionNames = [];
    try {
      var docSnapshot =
          await FirebaseFirestore.instance.collection('bus').doc(region).get();

      // Check if the document exists and contains the 'subcollections' field
      if (docSnapshot.exists &&
          docSnapshot.data()!.containsKey('subcollections')) {
        var subcollections = docSnapshot.data()!['subcollections'];
        subcollectionNames.addAll(subcollections.cast<String>());
      }
    } catch (e) {
      print('Error fetching subcollections: $e');
    }
    return subcollectionNames;
  }

  Future<void> fetchBusStations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bus')
          .doc(selectedRegion)
          .collection(selectedBus!)
          .get();

      for (var doc in querySnapshot.docs) {
        print('Document ID: ${doc.id}');
        String latitudeStr = doc['latitude'];
        String longitudeStr = doc['longitude'];
        double latitude = double.parse(latitudeStr);
        double longitude = double.parse(longitudeStr);
        String name = doc.id;
        print(
            'Station name: $name, Latitude: $latitude, Longitude: $longitude');

        setState(() {
          markers.add(Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(latitude, longitude),
            child: Container(
              child: const Icon(
                Icons.directions_bus,
                color: Colors.black, // Color of the marker
              ),
            ),
          ));
        });
      }
      print('Markers: $markers');
    } catch (e) {
      print('Error fetching bus stations: $e');
    }
  }

  void filterRouteData() {
    for (var cityData in data) {
      if (cityData['city'] == selectedRegion) {
        for (var busStation in cityData['busStations']) {
          if (busStation['name'] == selectedBus) {
            List<LatLng> points = [];
            for (var point in busStation['circuit']) {
              var latLng = point['LatLng'];
              points.add(LatLng(latLng[0], latLng[1]));
            }
            setState(() {
              polylines.add(
                Polyline(
                  points: points,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              );
            });
          }
        }
      }
    }
  }

  void _handleSubmit() async {
    fetchRegions();
    await fetchBusStations();
    filterRouteData();

    // Set up a listener for real-time database updates
    locationStream(selectedBus!).listen((newPoint) {
      print('New point received: $newPoint');
      setState(() {
        fetchedPointPosition = newPoint;
      });
    });

    // Set up a listener for the alert status
    final alertsRef = FirebaseDatabase.instance
        .ref('alerts/$selectedBus');
    alertSubscription = alertsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        bool newAlertStatus = event.snapshot.value as bool;
        setState(() {
          hasAlert = newAlertStatus;
        });
      } else {
        print('Alert data not found for route: $selectedBus');
      }
    }, onError: (Object error) {
      print('Failed to fetch alert data: $error');
    });

    setState(() {
      _formVisible = false;
    });
  }

  void _toggleAlertStatus() async {
    final alertsRef = FirebaseDatabase.instance.ref('alerts/$selectedBus');
    bool newAlertStatus = !hasAlert;
    try {
      await alertsRef.set(newAlertStatus);
      setState(() {
        hasAlert = newAlertStatus;
      });
    } catch (error) {
      print('Failed to update alert status: $error');
    }
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (polylines.isEmpty && markers.isEmpty && !_formVisible)
            const Center(child: CircularProgressIndicator())
          else
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(37.276039, 9.877620),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: polylines,
                ),
                MarkerLayer(
                  markers: markers,
                ),
                if (fetchedPointPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: fetchedPointPosition!,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          Positioned(
            top: 30,
            left: 10,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Profile()));
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 10,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _formVisible = !_formVisible; 
                  });
                },
                icon: const Icon(
                  Icons.list,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildZoomButton(Icons.zoom_in, _zoomIn),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.zoom_out, _zoomOut),
              ],
            ),
          ),
          if (_formVisible) _buildFullScreenSelectionForm(),
          if (!_formVisible)
            Positioned(
              bottom: 30,
              right: 10,
              child: ElevatedButton(
                onPressed: _toggleAlertStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAlert ? Colors.red : Colors.green,
                ),
                child: Text(
                  hasAlert ? 'Alert: ON' : 'Alert: OFF',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullScreenSelectionForm() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<List<String>>(
                  stream: fetchRegions(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    List<String>? regions = snapshot.data;
                    if (regions == null || regions.isEmpty) {
                      return const Text('No regions found');
                    }
                    if (!regions.contains(selectedRegion)) {
                      selectedRegion = null;
                    }
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: DropdownButton<String>(
                        value: selectedRegion,
                        hint: const Text('Select Region'),
                        onChanged: (newValue) {
                          setState(() {
                            selectedRegion = newValue;
                            selectedBus = null;
                          });
                        },
                        items: regions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                FutureBuilder<List<String>>(
                  future: selectedRegion != null
                      ? fetchSubcollections(selectedRegion!)
                      : Future.value(
                          []),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    List<String> subcollectionNames = snapshot.data ?? [];
                    return ListTile(
                      leading: const Icon(Icons.directions_bus),
                      title: DropdownButton<String>(
                        value: selectedBus,
                        hint: const Text('Select Route'),
                        onChanged: selectedRegion == null
                            ? null
                            : (newValue) {
                                setState(() {
                                  selectedBus = newValue;
                                  markers.clear(); 
                                  polylines.clear(); 
                                  fetchBusStations();
                                  filterRouteData();
                                });
                              },
                        items: subcollectionNames
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
