import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TestListe extends StatefulWidget {
  // const TestListe({super.key, Key? key});

  @override
  State<TestListe> createState() => _TestListeState();
}

class _TestListeState extends State<TestListe> {
  String? _selectedBusLocation;
  String? _selectedSubcollection;
  String? _selectedDocument;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const IconButton(
          icon: Icon(FontAwesomeIcons.bars, color: Colors.blue),
          onPressed: null,
        ),
        title: Container(
          alignment: Alignment.topCenter,
          child: const Text(
            "Bus Navigator",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
      body: Form(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("bus").snapshots(),
              builder: (context, querySnapshot) {
                if (querySnapshot.hasData) {
                  List<DropdownMenuItem<String>> busLocations = [];
                  busLocations.add(
                    const DropdownMenuItem(
                      value: null,
                      child: Text(
                        "Select a region",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                  for (int i = 0; i < querySnapshot.data!.docs.length; i++) {
                    QueryDocumentSnapshot snapshot =
                        querySnapshot.data!.docs[i];
                    busLocations.add(DropdownMenuItem(
                      value: snapshot.id,
                      child: Text(
                        snapshot.id,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ));
                  }
                  return DropdownButton<String>(
                    items: busLocations,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedBusLocation = value;
                        // Reset selected subcollection and document when a new bus location is selected
                        _selectedSubcollection = null;
                        _selectedDocument = null;
                      });
                    },
                    value: _selectedBusLocation,
                  );
                } else {
                  return const Text("Loading");
                }
              },
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _selectedBusLocation != null
                  ? FirebaseFirestore.instance
                      .collection("bus")
                      .doc(_selectedBusLocation)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (_selectedBusLocation != null) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    List<dynamic>? subcollectionNames =
                        snapshot.data!.get('subcollections');
                    if (subcollectionNames != null &&
                        subcollectionNames.isNotEmpty) {
                      List<DropdownMenuItem<String>> subcollectionItems = [];
                      subcollectionItems.add(
                        const DropdownMenuItem(
                          value: null,
                          child: Text(
                            "Select a route",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                      for (String subcollectionName in subcollectionNames) {
                        subcollectionItems.add(
                          DropdownMenuItem(
                            value: subcollectionName,
                            child: Text(
                              subcollectionName,
                              style: const TextStyle(color: Colors.blue),
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
                        disabledHint: const Text(
                          "Select a region first",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    } else {
                      return const Text("No subcollections found");
                    }
                  } else {
                    return const Text("Select a region first");
                  }
                }
                // If the first dropdown doesn't have a selection
                return DropdownButton<String>(
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        "Select a region first",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                  onChanged: null,
                  value: null,
                  disabledHint: const Text(
                    "Select a bus location first",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream:
                  _selectedSubcollection != null && _selectedBusLocation != null
                      ? FirebaseFirestore.instance
                          .collection("bus")
                          .doc(_selectedBusLocation!)
                          .collection(_selectedSubcollection!)
                          .snapshots()
                      : null,
              builder: (context, snapshot) {
                if (_selectedSubcollection != null &&
                    _selectedBusLocation != null) {
                  if (snapshot.hasData) {
                    List<DropdownMenuItem<String>> documentItems = [];
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
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      );
                    }
                    return DropdownButton<String>(
                      items: documentItems,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedDocument = value;
                        });
                      },
                      value: _selectedDocument,
                      disabledHint: const Text(
                        "Select a subcollection first",
                        style: TextStyle(color: Colors.grey),
                      ),
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
                  disabledHint: const Text(
                    "Select a route first",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _selectedDocument != null &&
                        _selectedBusLocation != null &&
                        _selectedSubcollection != null
                    ? FirebaseFirestore.instance
                        .collection("bus")
                        .doc(_selectedBusLocation!)
                        .collection(_selectedSubcollection!)
                        .doc(_selectedDocument!)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    // Display your document data here
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['subtitle']),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return const Center(
                      child: Text(''),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
