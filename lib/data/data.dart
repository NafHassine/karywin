import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

// ! Routing
int currentIndex = 0;
// ! Routing

List bottomBar = [
  const Icon(
    Ionicons.home_outline,
    color: Colors.white,
  ),
  const Icon(
    Ionicons.compass_outline,
    color: Colors.white,
  ),
  const Icon(
    Ionicons.bookmark_outline,
    color: Colors.white,
  ),
  const Icon(
    Ionicons.person_outline,
    color: Colors.white,
  ),
];

List data = [
  {
    "city": 'Bizerte',
    "country": 'Tunisie',
    "rating": '4.6',
    'image': 'assets/images/Bizerte.jpg',
    "LatLng": '9.875061,37.875061',
    "busStations": [
      {
        "name": "be7ira",
        "circuit": [
          {"lat": 37.274573, "lng": 9.875061},
          {"lat": 37.274573, "lng": 9.875061},
          {"lat": 37.274573, "lng": 9.875061},
        ]
      },
      {
        "name": "corniche 21",
        "circuit": [
          {"lat": 37.274573, "lng": 9.875061},
          {"lat": 37.274573, "lng": 9.875061},
          {"lat": 37.274573, "lng": 9.875061}
        ]
      },
      {
        "name": "nathour",
        "circuit": ["lat,lnt", "lat,lnt"]
      }
    ]
  },
  {
    "city": 'Tunis',
    "country": 'Tunisie',
    "rating": '4.8',
    'image': 'assets/images/tunis.jpg'
  },
  {
    "city": 'Sousse',
    "country": 'Tunisie',
    "rating": '4.4',
    'image': 'assets/images/sousse.jpg'
  },
  {
    "city": 'Sfax',
    "country": 'Tunisie',
    "rating": '4.5',
    'image': 'assets/images/sfax.jpg'
  },
];
List data_2 = [
  {"name": 'Flaye', 'image': 'assets/images/flaye.png'},
  {"name": 'Beach', 'image': 'assets/images/beach.png'},
  {"name": 'Park', 'image': 'assets/images/park.png'},
  {"name": 'Camp', 'image': 'assets/images/camp.png'},
];
final categoryList = ['Populare', 'Recommended', 'Most Viewd', 'Most Liked'];

// Colors
const kAvatarColor = Color(0xffffdbc9);
const kPrimaryColor = Color(0xFFEEF7FF);
const kSecondaryColor = Color(0xFF29303D);
