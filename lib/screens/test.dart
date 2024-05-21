import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/data.dart'; // Import your local data
import 'package:firebase_auth/firebase_auth.dart';

class DriverRouteScreen extends StatefulWidget {
  @override
  _DriverRouteScreenState createState() => _DriverRouteScreenState();
}

class _DriverRouteScreenState extends State<DriverRouteScreen> {
  String driverCity = '';
  String driverBusStationID = '';
  List<Polyline> polylines = [];
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    fetchDriverData();
    fetchBusStations();
  }

  Future<void> fetchDriverData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser.uid;

      try {
        DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        setState(() {
          driverCity = driverSnapshot['City'];
          driverBusStationID = driverSnapshot['ID'];
        });

        filterRouteData();
        fetchBusStations();
      } catch (e) {
        print('Error fetching driver data: $e');
        // Handle the error appropriately in your app
      }
    } else {
      print('No user is currently signed in.');
      // Handle the error appropriately in your app
    }
  }

  Future<void> fetchBusStations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bus')
          .doc(driverCity)
          .collection(driverBusStationID)
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
                Icons.directions_bus_filled_outlined,
                color: Colors.red, // Color of the marker
              ),
            ),
          ));
        });
      }
      print('Markers: $markers');
    } catch (e) {
      print('Error fetching bus stations: $e');
      // Handle the error appropriately in your app
    }
  }

  void filterRouteData() {
    for (var cityData in data) {
      if (cityData['city'] == driverCity) {
        for (var busStation in cityData['busStations']) {
          if (busStation['name'] == driverBusStationID) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Route'),
      ),
      body: polylines.isEmpty && markers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(37.276039, 9.877620),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                PolylineLayer(
                  polylines: polylines,
                ),
                MarkerLayer(
                  markers: markers,
                )
              ],
            ),
    );
  }
}
