import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

class Methods {
  static DatabaseReference getLocationRef(String selectedSubcollection) {
    return FirebaseDatabase.instance
        .ref()
        .child('Locations/$selectedSubcollection');
  }

  static Future<LatLng?> fetchLocationData(String selectedSubcollection) async {
    DatabaseReference locationRef = getLocationRef(selectedSubcollection);
    DatabaseEvent event = await locationRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> locationData =
          snapshot.value as Map<dynamic, dynamic>;
      double latitude = (locationData['Latitude']);
      double longitude = (locationData['Longitude']);
      return LatLng(latitude, longitude);
    } else {
      return null;
    }
  }

  static Stream<LatLng?> locationStream(String selectedSubcollection) {
    DatabaseReference locationRef = getLocationRef(selectedSubcollection);
    return locationRef.onValue.map((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> locationData =
            snapshot.value as Map<dynamic, dynamic>;
        double latitude = (locationData['Latitude']);
        double longitude = (locationData['Longitude']);
        return LatLng(latitude, longitude);
      } else {
        return null;
      }
    });
  }
}
