import 'package:kary_win/data/data.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kary_win/screens/auth/new_signup.dart';
import 'package:kary_win/screens/profile/profile.dart';
import '../screens/home.dart';

class Routing extends StatefulWidget {
  const Routing({super.key});

  @override
  State<Routing> createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {
  List routing = [
    const Home(),
    {},
    const NewSignupPage(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        routing.elementAt(currentIndex),
        //condition bech matodhhorch el nav bar fi screens mou3aynin
        //if (currentIndex != 0)
        //--------------------------------
        Container(
          margin: EdgeInsets.all(displayWidth * .05),
          height: displayWidth * .155,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              //colour mta3 nav bar
              gradient: LinearGradient(colors: [
                Color.fromRGBO(143, 148, 251, 1),
                Color.fromRGBO(143, 148, 251, .6),
              ]),
              borderRadius: BorderRadius.all(Radius.circular(35))),
          child: currentIndex == 4
              ? GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Go To Map",
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
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...List.generate(bottomBar.length, (i) {
                      return GestureDetector(
                        onTap: () => setState(() {
                          currentIndex = i;
                          print("Current Index: $currentIndex");
                        }),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            bottomBar[i],
                            const SizedBox(height: 4),
                            currentIndex == i
                                ? Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      );
                    })
                  ],
                ),
        ),
      ],
    ));
  }
}
