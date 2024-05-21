import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(51.5, -0.09),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: const LatLng(51.5, -0.09),
                      child: Container(
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Schedule Section
          Expanded(
            child: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.stop),
                  title: Text('Stop 1'),
                  subtitle: Text('Expected Time: 10:00 AM'),
                ),
                ListTile(
                  leading: Icon(Icons.stop),
                  title: Text('Stop 2'),
                  subtitle: Text('Expected Time: 10:30 AM'),
                ),
              ],
            ),
          ),
          // Communication Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Report Issue'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
