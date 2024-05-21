import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> data; // List of polylines
  final Map<String, dynamic> firebasePoint; // Point retrieved from Firebase

  const MapScreen({super.key, required this.data, required this.firebasePoint});

  @override
  Widget build(BuildContext context) {
    // Check if data is not null and not empty
    if (data.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No data to display'),
        ),
      );
    }

    // Convert data to polylines with LatLng points
    List<LatLng> polylinePoints = data.map((point) {
      final double lat = point['lat'] as double;
      final double lng = point['lng'] as double;
      return LatLng(lat, lng);
    }).toList();

    // Marker for the point retrieved from Firebase
    LatLng firebaseMarkerPosition =
        LatLng(firebasePoint['lat'] as double, firebasePoint['lng'] as double);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Polyline and Marker'),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(37.276171, 9.860017), // Initial center position
          initialZoom: 15, // Initial zoom level
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
                color: Colors.blue, // Color of the polyline
                strokeWidth: 6, // Width of the polyline
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: firebaseMarkerPosition,
                // Provide a child widget for the marker
                child: Container(
                  child: const Icon(
                    Icons.directions_bus_filled_outlined,
                    color: Colors.red, // Color of the marker
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
