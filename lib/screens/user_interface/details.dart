import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kary_win/screens/user_interface/methods.dart';
import 'package:kary_win/screens/user_interface/user_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/data.dart';

class Details extends StatefulWidget {
  final int index;
  final String hero;
  const Details({super.key, required this.index, required this.hero});

  @override
  State<Details> createState() => DdetailsState();
}

class DdetailsState extends State<Details> {
  late DocumentSnapshot selectedDocumentSnapshot;
  late List<Map<String, dynamic>> _formattedPoints = [];
  late Map<String, double> firebasePoint;
  final _controller = ScrollController();
  String? _selectedSubcollection;
  String? _selectedDocument;
  ScrollPhysics _physics = const ClampingScrollPhysics();
  bool appBarVAR = false;
  bool bottomBarImagesVAR = false;
  Map<String, double>? _fetchedLocationData;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {
    _fetchData();
    _fetchedLocationData;
    _runAnimation();
    _controller.addListener(() {
      if (_controller.position.pixels <= 100) {
        setState(() => _physics = const ClampingScrollPhysics());
      } else {
        setState(() => _physics = const BouncingScrollPhysics());
      }
    });
  }

  void _launchMapsUrl(String place) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place)}&travelmode=driving&dir_action=navigate";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  Future<void> _fetchData() async {
    try {
      await _fetchDocumentSnapshot(
          "bus/${data[widget.index]["city"]}/$_selectedSubcollection/$_selectedDocument");
      _processData(selectedDocumentSnapshot);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _fetchDocumentSnapshot(String docPath) async {
    selectedDocumentSnapshot =
        await FirebaseFirestore.instance.doc(docPath).get();
  }

  Future<void> _processDataLocal() async {
    // Find the selected route
    var selectedRoute = await data
        .firstWhere((element) => element['city'] == data[widget.index]["city"]);
    print(selectedRoute['city']);

    // Find the selected station in the selected route
    var selectedStation = await selectedRoute['busStations'].firstWhere(
      (element) => element['name'] == _selectedSubcollection,
    );
    print(selectedStation['name']);

    if (selectedStation != null) {
      var circuit = selectedStation['circuit'] as List<dynamic>;
      _formattedPoints = circuit.map((circuitPoint) {
        double lat = circuitPoint['LatLng'][0];
        double lng = circuitPoint['LatLng'][1];
        return {'lat': lat, 'lng': lng};
      }).toList();
      print(_formattedPoints);
    } else {
      print('No station found for $_selectedSubcollection');
    }
  }

  void _processData(DocumentSnapshot documentSnapshot) {
    var latitudeString = documentSnapshot['latitude'] as String?;
    var longitudeString = documentSnapshot['longitude'] as String?;
    print('Latitude String: $latitudeString');
    print('Longitude String: $longitudeString');

    double? latitude =
        latitudeString != null ? double.tryParse(latitudeString) : null;
    double? longitude =
        longitudeString != null ? double.tryParse(longitudeString) : null;
    print('Parsed Latitude: $latitude');
    print('Parsed Longitude: $longitude');

    if (latitude != null && longitude != null) {
      firebasePoint = {
        'lat': latitude,
        'lng': longitude,
      };
    } else {
      print('Latitude or longitude is not a valid double');
    }
  }

  Future<void> _runAnimation() async {
    await Future.delayed(const Duration(milliseconds: 350));
    setState(() {
      appBarVAR = true;
      bottomBarImagesVAR = true;
    });
  }

  Future<void> _fetchLocationData(Map<String, double>? locationData) async {
    try {
      LatLng? location =
          await Methods.fetchLocationData(_selectedSubcollection!);
      if (location != null) {
        print('Location fetched: $location');
        // Convert LatLng to a Map<String, double>
        Map<String, double> fetchedData = {
          'Latitude': location.latitude,
          'Longitude': location.longitude,
        };
        setState(() {
          _fetchedLocationData = fetchedData;
        });
      } else {
        print('Location data not found');
      }
    } catch (e) {
      debugPrint("Error fetching location data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    double displayHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _controller,
              physics: _physics,
              child: Column(
                children: [
                  Material(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40)),
                    elevation: 4,
                    child: Hero(
                      tag: widget.hero,
                      child: Container(
                        height: displayHeight / 2,
                        width: displayWidth,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          image: DecorationImage(
                            image: AssetImage(data[widget.index]["image"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AnimatedCrossFade(
                              firstChild: Container(),
                              secondChild: appBar(),
                              crossFadeState: appBarVAR
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 400),
                            ),
                            AnimatedCrossFade(
                              firstChild: Container(),
                              secondChild: bottomBarImages(),
                              crossFadeState: appBarVAR
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: displayWidth,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[widget.index]["city"],
                              style: const TextStyle(
                                color: kSecondaryColor,
                                fontSize: 25,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              data[widget.index]["country"],
                              style: const TextStyle(
                                color: kSecondaryColor,
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black38.withOpacity(0.2),
                    endIndent: 20,
                    indent: 20,
                    height: 4,
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 100,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dropdown
                        SingleChildScrollView(
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("bus")
                                .doc(data[widget.index]["city"])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.exists) {
                                List<dynamic>? subcollectionNames =
                                    snapshot.data!.get('subcollections');
                                if (subcollectionNames != null &&
                                    subcollectionNames.isNotEmpty) {
                                  List<DropdownMenuItem<String>>
                                      subcollectionItems = [];
                                  subcollectionItems.add(
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text(
                                        "Select a route",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                  for (String subcollectionName
                                      in subcollectionNames) {
                                    subcollectionItems.add(
                                      DropdownMenuItem(
                                        value: subcollectionName,
                                        child: Text(
                                          subcollectionName,
                                          style: const TextStyle(
                                              color: Colors.black45),
                                        ),
                                      ),
                                    );
                                  }
                                  return DropdownButton<String>(
                                    items: subcollectionItems,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedSubcollection = value;
                                        // Reset selected document when a new subcollection is selected
                                        _selectedDocument = null;
                                      });
                                    },
                                    value: _selectedSubcollection,
                                    style: const TextStyle(
                                        color: Colors.black45, fontSize: 16.0),
                                    elevation: 4,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    underline: Container(),
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                  );
                                } else {
                                  return const Text("No subcollections found");
                                }
                              } else {
                                return const Text("Select a region first");
                              }
                            },
                          ),
                        ),
                        // Dropdown
                        SingleChildScrollView(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _selectedSubcollection != null
                                ? FirebaseFirestore.instance
                                    .collection("bus")
                                    .doc(data[widget.index]["city"])
                                    .collection(_selectedSubcollection!)
                                    .snapshots()
                                : null,
                            builder: (context, snapshot) {
                              if (_selectedSubcollection != null) {
                                if (snapshot.hasData) {
                                  List<DropdownMenuItem<String>> documentItems =
                                      [];
                                  documentItems.add(
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text(
                                        "Select a station",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                  for (QueryDocumentSnapshot docSnapshot
                                      in snapshot.data!.docs) {
                                    documentItems.add(
                                      DropdownMenuItem(
                                        value: docSnapshot.id,
                                        child: Text(
                                          docSnapshot.id,
                                          style: const TextStyle(
                                              color: Colors.black45),
                                        ),
                                      ),
                                    );
                                  }
                                  return DropdownButton<String>(
                                    items: documentItems,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedDocument = value;
                                        print(
                                            'Selected Document: $_selectedDocument');
                                        // After selecting the station, navigate to the MapScreen
                                        if (_selectedSubcollection != null &&
                                            _selectedDocument != null) {
                                          _processDataLocal();
                                          _fetchData();
                                          _fetchLocationData(
                                              _fetchedLocationData);
                                        }
                                      });
                                    },
                                    value: _selectedDocument,
                                    style: const TextStyle(
                                        color: Colors.blue, fontSize: 16.0),
                                    elevation: 4,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    underline: Container(),
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }
                              }
                              // If the second dropdown doesn't have a selection
                              return DropdownButton<String>(
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      "Select a route first",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ],
                                onChanged: null,
                                value: null,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                                elevation: 0,
                                underline: Container(),
                                isExpanded: true,
                                dropdownColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 200,
                    width: displayWidth,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      image: DecorationImage(
                        image: AssetImage(data[widget.index]["image1"]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(displayWidth * .05),
            height: displayWidth * .155,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromRGBO(143, 148, 251, 6),
                Color.fromRGBO(143, 148, 251, .6),
              ]),
              borderRadius: BorderRadius.all(Radius.circular(35)),
            ),
            child: GestureDetector(
              onTap: () {
                print("Formatted points before navigation: $_formattedPoints");
                if (_formattedPoints.isNotEmpty &&
                    _fetchedLocationData != null) {
                  print("Navigating to MapScreen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                          data: _formattedPoints,
                          firebasePoint: firebasePoint,
                          fetchedPoint: _fetchedLocationData ?? {},
                          selectedSubcollection: _selectedSubcollection!),
                    ),
                  ).then((value) {
                    print("Returned from MapScreen");
                  }).catchError((error) {
                    print("Navigation Error: $error");
                  });
                } else {
                  print("Formatted points are empty");
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Go To Map ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Ionicons.arrow_forward_outline,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return Row(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  width: 48,
                  height: 48,
                  color: Colors.white,
                  child: const Icon(
                    Ionicons.arrow_back_outline,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Padding(
        //     padding: const EdgeInsets.all(12),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(32),
        //       child: Material(
        //         color: Colors.white, // needed for InkWell to work correctly
        //         child: InkWell(
        //           onTap: () {
        //             _launchMapsUrl(data[widget.index]["city"]);
        //           },
        //           child: Container(
        //             width: 48,
        //             height: 48,
        //             alignment: Alignment.center, // center the icon
        //             child: const Icon(
        //               Ionicons.download_outline,
        //               color: Colors.black87,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: Padding(
        //     padding: const EdgeInsets.all(12),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(32),
        //       child: Container(
        //         width: 48,
        //         height: 48,
        //         color: Colors.white,
        //         child: const Icon(
        //           FontAwesomeIcons.heart,
        //           color: Colors.black87,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget bottomBarImages() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              height: 90,
              color: kSecondaryColor.withOpacity(0.25),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    ...List.generate(
                      data.length,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24)),
                                    image: DecorationImage(
                                      image: AssetImage(data[index]["image"]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                index == (data.length - 1)
                                    ? Container(
                                        color: Colors.blue.shade800
                                            .withOpacity(0.4),
                                        child: const Center(
                                          child: Text(
                                            "+5",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
