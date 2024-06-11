import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Location> {
  late MapOptions _mapOptions;
  LatLng? _currentLocation;
  final double _zoom = 5;
  List<LatLng> stationPoints = [];
  List<String> stationIds = [];
  List<String> stationCollections = [];
  final List<int> _radiusOptions = [100, 200, 300];
  int _selectedRadius = 100;

  // Définissez une liste de noms de collections pour les stations
  List<String> _stations = ['Ain Mariem', 'Corniche', 'Manzel Abderrahmen'];

  @override
  void initState() {
    super.initState();
    _currentLocation = const LatLng(0, 0);
    _getCurrentLocation();
    _mapOptions = MapOptions(
      initialCenter: _currentLocation!,
      initialZoom: _zoom,
    );

    fetchStationCoordinates();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _buildMap() {
    return FlutterMap(
      options: _mapOptions,
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          backgroundColor: Colors.transparent,
        ),
        MarkerLayer(
          markers: [
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    _showCurrentLocationDialog(context, _currentLocation!);
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
              ),
            for (int i = 0; i < stationPoints.length; i++)
              if (_currentLocation != null &&
                  _calculateDistance(
                          _currentLocation!.latitude,
                          _currentLocation!.longitude,
                          stationPoints[i].latitude,
                          stationPoints[i].longitude) <=
                      _selectedRadius)
                Marker(
                  point: stationPoints[i],
                  width: 60,
                  height: 60,
                  // Child pour afficher l'ID de la station et le nom de la collection
                  child: GestureDetector(
                    onTap: () {
                      _showStationInfoDialog(
                          context, stationIds[i], stationCollections[i]);
                    },
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                  ),
                ),
          ],
        ),
        CircleLayer(
          circles: [
            if (_currentLocation != null)
              CircleMarker(
                point: _currentLocation!,
                color: Colors.red.withOpacity(0.5),
                borderColor: Colors.red,
                borderStrokeWidth: 2,
                radius: _selectedRadius.toDouble(),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          DropdownButton<int>(
            value: _selectedRadius,
            onChanged: (value) {
              setState(() {
                _selectedRadius = value!;
              });
            },
            items: _radiusOptions.map((radius) {
              return DropdownMenuItem<int>(
                value: radius,
                child: Text('$radius meters'),
              );
            }).toList(),
          ),
          Expanded(
            child: _buildMap(),
          ),
        ],
      ),
    );
  }

  Future<void> _showCurrentLocationDialog(
      BuildContext context, LatLng currentLocation) async {
    List<String> stationIdsInRadius = getStationIdsInRadius(
        currentLocation, stationPoints, _selectedRadius as double);

    // Afficher la boîte de dialogue avec les IDs des stations à l'intérieur du cercle
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Current Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Latitude: ${currentLocation.latitude}, Longitude: ${currentLocation.longitude}'),
              const SizedBox(height: 10),
              Text('Stations within $_selectedRadius meters:'),
              const SizedBox(height: 5),
              for (int i = 0; i < stationIdsInRadius.length; i++)
                Text('- ${stationIdsInRadius[i]}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchStationCoordinates() async {
    try {
      final collection = FirebaseFirestore.instance.collection('bus');
      for (String stationName in _stations) {
        final doc =
            await collection.doc('Bizerte').collection(stationName).get();
        if (doc.docs.isNotEmpty) {
          doc.docs.forEach((docSnapshot) {
            final data = docSnapshot.data();
            final String? latitude = data['latitude'] as String?;
            final String? longitude = data['longitude'] as String?;
            final String? id =
                docSnapshot.id; // Store the Firestore document ID
            if (latitude != null && longitude != null && id != null) {
              setState(() {
                stationPoints.add(
                  LatLng(double.parse(latitude), double.parse(longitude)),
                );
                stationIds.add(
                    id); // Store the Firestore document ID for the station
                stationCollections.add(
                    stationName); // Store the collection name for the station
              });
            } else {
              print('Latitude, longitude, or ID is null');
            }
                    });
        } else {
          print('Document does not exist');
        }
      }
    } on FirebaseException catch (e) {
      print('Firestore Error: ${e.message}');
    } catch (e) {
      print('Error fetching station data: $e');
    }
  }

  List<String> getStationIdsInRadius(LatLng currentLocation,
      List<LatLng> stationLocations, double selectedRadius) {
    List<String> stationIdsInRadius = [];
    for (int i = 0; i < stationLocations.length; i++) {
      LatLng stationPoint = stationLocations[i];
      double distance = _calculateDistance(
          currentLocation.latitude,
          currentLocation.longitude,
          stationPoint.latitude,
          stationPoint.longitude);
      if (distance <= selectedRadius) {
        // Find the ID corresponding to the LatLng point
        String stationId = getStationIdForPoint(stationPoint);
        stationIdsInRadius.add(stationId);
      }
    }
    return stationIdsInRadius;
  }

  String getStationIdForPoint(LatLng point) {
    // Iterate through stationPoints to find the corresponding LatLng point
    for (int i = 0; i < stationPoints.length; i++) {
      if (stationPoints[i] == point) {
        // Return the Firestore document ID of the corresponding snapshot
        return stationIds[i];
      }
    }
    return "Unknown"; // If no matching point found, return "Unknown"
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Rayon de la terre en km
    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c;
    return distance * 1000; // Convertir en mètres
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  // Fonction pour afficher la pop-up avec les informations de la station
  Future<void> _showStationInfoDialog(
      BuildContext context, String stationId, String stationCollection) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Station Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Station : $stationId'),
              const SizedBox(height: 10),
              Text('BUS NAME: $stationCollection'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
