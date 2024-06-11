import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'methods.dart';

class MapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data; 
  final Map<String, dynamic> firebasePoint; 
  final Map<String, double> fetchedPoint;
  final String selectedSubcollection;

  const MapScreen({
    super.key,
    required this.data,
    required this.firebasePoint,
    required this.fetchedPoint,
    required this.selectedSubcollection,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng fetchedPointPosition;
  final MapController _mapController = MapController();
  Duration? estimatedTime;
  late List<LatLng> polylinePoints;
  bool hasAlert = false; 

  StreamSubscription<DatabaseEvent>? alertSubscription;

  @override
  void initState() {
    super.initState();
    setupAlertStream(widget.selectedSubcollection);
    // Initialize fetchedPointPosition
    fetchedPointPosition = LatLng(
      widget.fetchedPoint['Latitude']!,
      widget.fetchedPoint['Longitude']!,
    );
    // Convert data to polylines with LatLng points
    polylinePoints = widget.data.map((point) {
      final double lat = point['lat'] as double;
      final double lng = point['lng'] as double;
      return LatLng(lat, lng);
    }).toList();

    // Set up a listener for real-time database updates
    Methods.locationStream(widget.selectedSubcollection).listen((newPoint) {
      if (newPoint != null) {
        print('New point received: $newPoint');
        setState(() {
          fetchedPointPosition = newPoint;

          // Calculate the estimated time to reach the station
          double distance =
              calculateRouteDistance(polylinePoints, fetchedPointPosition);
          estimatedTime = estimateTime(
              distance, 20); // Assuming average bus speed is 20 km/h
        });
      }
    });
  }

  @override
  void dispose() {
    cancelAlertStream();
    super.dispose();
  }

  void setupAlertStream(String routeIdentifier) {
    DatabaseReference alertsRef =
        FirebaseDatabase.instance.ref().child('alerts/$routeIdentifier');
    alertSubscription = alertsRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        bool? hasAlertValue = event.snapshot.value as bool?;
        setState(() {
          hasAlert = hasAlertValue ?? false;
        });
      } else {
        print('Alert data not found for route: $routeIdentifier');
      }
    }, onError: (Object error) {
      print('Failed to fetch alert data: $error');
    });
  }

  void cancelAlertStream() {
    if (alertSubscription != null) {
      alertSubscription!.cancel();
    }
  }

  double calculateRouteDistance(
      List<LatLng> polylinePoints, LatLng currentPosition) {
    double totalDistance = 0.0;
    Distance distance = const Distance();

    // Find the closest point on the polyline to the current position
    LatLng? closestPoint;
    double closestDistance = double.infinity;
    for (int i = 0; i < polylinePoints.length - 1; i++) {
      LatLng point = polylinePoints[i];
      double dist = distance.as(LengthUnit.Meter, currentPosition, point);
      if (dist < closestDistance) {
        closestDistance = dist;
        closestPoint = point;
      }
    }

    // Sum distances from the closest point to the end of the polyline
    if (closestPoint != null) {
      bool startSumming = false;
      for (int i = 0; i < polylinePoints.length - 1; i++) {
        if (polylinePoints[i] == closestPoint) {
          startSumming = true;
        }
        if (startSumming) {
          totalDistance += distance.as(
              LengthUnit.Meter, polylinePoints[i], polylinePoints[i + 1]);
        }
      }
    }

    return totalDistance / 1000; // Convert to kilometers
  }

  Duration estimateTime(double distance, double speed) {
    // Speed should be in km/h, distance in km
    // Convert speed to km/min (divide by 60)
    double speedPerMinute = speed / 60;
    double estimatedMinutes = distance / speedPerMinute;
    return Duration(minutes: estimatedMinutes.round());
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
    // Check if data is not null and not empty
    if (widget.data.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No data to display'),
        ),
      );
    }

    // Convert data to polylines with LatLng points
    polylinePoints = widget.data.map((point) {
      final double lat = point['lat'] as double;
      final double lng = point['lng'] as double;
      return LatLng(lat, lng);
    }).toList();

    // Marker for the point retrieved from Firebase
    LatLng firebaseMarkerPosition = LatLng(
      widget.firebasePoint['lat'] as double,
      widget.firebasePoint['lng'] as double,
    );

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter:
                  LatLng(37.276171, 9.860017), // Initial center position
              initialZoom: 13, // Initial zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color: Colors.blue, 
                    strokeWidth: 6, 
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: firebaseMarkerPosition,
                    child: const Icon(
                      Icons.directions_bus_filled,
                      color: Colors.black, 
                      size: 40,
                    ),
                  ),
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: fetchedPointPosition,
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
            top: 40, 
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
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
          if (estimatedTime != null)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Estimated time: ${estimatedTime!.inMinutes} minutes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          if (hasAlert)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white), 
                    SizedBox(width: 8),
                    Text(
                      'Bus Delay: There is a delay in the bus schedule.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
