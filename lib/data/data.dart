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
        "name": "Cité Bougatfa",
        "circuit": [
          {
            "LatLng": [37.276039, 9.877620]
          },
          {
            "LatLng": [37.272217, 9.871110]
          },
          {
            "LatLng": [37.274573, 9.875061]
          },
        ]
      },
      {
        "name": "corniche 21",
        "circuit": [
          {"LatLng": (37.274573, 9.875061)},
          {"LatLng": (37.274573, 9.875061)},
          {"LatLng": (37.274573, 9.875061)}
        ]
      },
      {
        "name": "Ain Mariem",
        "circuit": [
          {
            "LatLng": [37.274641, 9.875163]
          },
          {
            "LatLng": [37.273836, 9.873811]
          },
          {
            "LatLng": [37.272417, 9.871412]
          },
          {
            "LatLng": [37.271984, 9.870680]
          },
          {
            "LatLng": [37.271678, 9.870137]
          },
          {
            "LatLng": [37.271249, 9.869116]
          },
          {
            "LatLng": [37.270180, 9.866879]
          },
          {
            "LatLng": [37.269602, 9.865025]
          },
          {
            "LatLng": [37.269262, 9.86409]
          },
          {
            "LatLng": [37.268688, 9.862860]
          },
          {
            "LatLng": [37.267986, 9.861316]
          },
          {
            "LatLng": [37.267252, 9.859151]
          },
          {
            "LatLng": [37.266841, 9.858216]
          },
          {
            "LatLng": [37.267075, 9.857666]
          },
          {
            "LatLng": [37.267601, 9.857546]
          },
          {
            "LatLng": [37.268767, 9.857601]
          },
          {
            "LatLng": [37.270255, 9.857187]
          },
          {
            "LatLng": [37.271721, 9.856731]
          },
          {
            "LatLng": [37.273358, 9.856247]
          },
          {
            "LatLng": [37.274893, 9.855764]
          },
          {
            "LatLng": [37.275910, 9.855426]
          },
          {
            "LatLng": [37.277560, 9.855431]
          },
          {
            "LatLng": [37.278786, 9.855753]
          },
          {
            "LatLng": [37.279616, 9.856065]
          },
          {
            "LatLng": [37.279825, 9.856226]
          },
          {
            "LatLng": [37.280688, 9.856656]
          },
          {
            "LatLng": [37.281124, 9.856919]
          },
          {
            "LatLng": [37.281545, 9.857759]
          },
          {
            "LatLng": [37.282188, 9.858321]
          },
          {
            "LatLng": [37.282547, 9.858944]
          },
          {
            "LatLng": [37.282919, 9.859481]
          },
          {
            "LatLng": [37.283150, 9.859830]
          },
          {
            "LatLng": [37.283441, 9.860271]
          },
          {
            "LatLng": [37.283532, 9.860349]
          },
          {
            "LatLng": [37.283743, 9.860723]
          },
          {
            "LatLng": [37.283947, 9.861070]
          },
          {
            "LatLng": [37.284100, 9.861296]
          },
          {
            "LatLng": [37.284648, 9.862089]
          },
          {
            "LatLng": [37.284762, 9.862276]
          },
          {
            "LatLng": [37.284999, 9.862634]
          },
          {
            "LatLng": [37.285206, 9.862968]
          },
          {
            "LatLng": [37.285427, 9.863323]
          },
          {
            "LatLng": [37.285787, 9.863894]
          },
          {
            "LatLng": [37.286131, 9.864497]
          },
          {
            "LatLng": [37.286268, 9.864715]
          },
          {
            "LatLng": [37.286392, 9.864920]
          },
          {
            "LatLng": [37.286630, 9.865269]
          },
          {
            "LatLng": [37.286712, 9.865383]
          },
          {
            "LatLng": [37.286857, 9.865602]
          },
          {
            "LatLng": [37.287368, 9.866421]
          },
          {
            "LatLng": [37.288130, 9.867703]
          },
          {
            "LatLng": [37.288263, 9.867948]
          },
          {
            "LatLng": [37.288396, 9.867640]
          },
          {
            "LatLng": [37.288748, 9.867127]
          },
          {
            "LatLng": [37.289419, 9.866277]
          },
          {
            "LatLng": [37.290087, 9.865388]
          },
          {
            "LatLng": [37.290694, 9.864638]
          },
          {
            "LatLng": [37.290927, 9.864360]
          },
          {
            "LatLng": [37.291360, 9.863802]
          },
          {
            "LatLng": [37.291936, 9.863069]
          },
          {
            "LatLng": [37.292397, 9.862502]
          },
          {
            "LatLng": [37.293351, 9.861239]
          },
          {
            "LatLng": [37.293805, 9.860677]
          },
          {
            "LatLng": [37.294448, 9.859685]
          },
        ]
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
