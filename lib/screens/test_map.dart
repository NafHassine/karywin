// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_maps/maps.dart';
// import 'package:interactive_viewer_2/interactive_viewer_2.dart';

// class Map extends StatefulWidget {
//   @override
//   _mapState createState() => _mapState();
// }

// class _mapState extends State<Map> {
//   late List<MapLatLng> polyline;
//   late List<List<MapLatLng>> polylines;
//   late MapZoomPanBehavior zoomPanBehavior;

//   @override
//   void initState() {
//     polyline = <MapLatLng>[
//       const MapLatLng(37.274573, 9.875061),
//       const MapLatLng(37.271972, 9.867608),
//       const MapLatLng(37.273435, 9.865150),
//       const MapLatLng(37.276154, 9.859875),
//       const MapLatLng(37.276966, 9.858978),
//       const MapLatLng(37.277508, 9.857896),
//       const MapLatLng(37.280276, 9.855806),
//       const MapLatLng(37.282011, 9.854505),
//       const MapLatLng(37.284602, 9.852628),
//       const MapLatLng(37.286187, 9.852486),
//     ];

//     // for (var point in Crcuit) {
//     //   polyline.add(const MapLatLng(point.lng, point.lng))
//     // }
//     polylines = <List<MapLatLng>>[polyline];
//     zoomPanBehavior = MapZoomPanBehavior(
//       zoomLevel: 5,
//       focalLatLng: const MapLatLng(37.276171, 9.860017),
//     );
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Map with Polyline'),
//       ),
//       body: SfMaps(
//         layers: [
//           MapTileLayer(
//             urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//             sublayers: [
//               MapPolylineLayer(
//                 polylines: List<MapPolyline>.generate(
//                   polylines.length,
//                   (int index) {
//                     return MapPolyline(
//                       points: polylines[index],
//                     );
//                   },
//                 ).toSet(),
//               ),
//             ],
//             zoomPanBehavior: zoomPanBehavior,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:syncfusion_flutter_maps/maps.dart';
// // import 'package:kary_win/data/data.dart';

// // class MapScreen extends StatelessWidget {
// //   final List<Map<String, dynamic>> data; // Pass your data here

// //   const MapScreen({super.key, required this.data});

// //   @override
// //   Widget build(BuildContext context) {
// //     List<List<MapLatLng>> polylines = [];
// //     for (var item in data) {
// //       List<MapLatLng> polyline = [];
// //       var busStations = item['busStations'] as List<dynamic>;
// //       for (var station in busStations) {
// //         var circuit = station['circuit'] as List<dynamic>;
// //         for (var point in circuit) {
// //           double lat = point['lat'];
// //           double lng = point['lng'];
// //           polyline.add(MapLatLng(lat, lng));
// //         }
// //       }
// //       polylines.add(polyline);
// //     }

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Map with Polyline'),
// //       ),
// //       body: SfMaps(
// //         layers: [
// //           MapTileLayer(
// //             urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
// //             sublayers: [
// //               MapPolylineLayer(
// //                 polylines: polylines
// //                     .map((polyline) => MapPolyline(points: polyline))
// //                     .toSet(),
// //               ),
// //             ],
// //             zoomPanBehavior: MapZoomPanBehavior(
// //               zoomLevel: 5,
// //               focalLatLng: const MapLatLng(37.276171, 9.860017),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



