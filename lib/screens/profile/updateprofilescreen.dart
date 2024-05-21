import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:kary_win/screens/profile/constants.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(
          tEditProfile,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              // -- IMAGE with ICON
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: const Image(image: AssetImage('tProfileImage')),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        LineAwesomeIcons.camera,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                child: Column(
                  children: [
                    // Username field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: tUserName,
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Email field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: tEmail,
                        prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Phone number field
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: tPhoneNo,
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Password field
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: tPassword,
                        prefixIcon: const Icon(Icons.fingerprint),
                        suffixIcon: IconButton(
                          icon: const Icon(LineAwesomeIcons.eye_slash),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: tFormHeight),

                    // -- Form Submit Button
                    const SizedBox(
                      height: 20,
                    ),

                    // Edit Profile button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: tFormHeight),

                    // -- Created Date and Delete Button
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     // const Text.rich(
                    //     //   TextSpan(
                    //     //     text: tJoined,
                    //     //     style: TextStyle(fontSize: 12),
                    //     //     children: [
                    //     //       TextSpan(
                    //     //           text: tJoinedAt,
                    //     //           style: TextStyle(
                    //     //               fontWeight: FontWeight.bold,
                    //     //               fontSize: 12))
                    //     //     ],
                    //     //   ),
                    //     // ),
                    //     ElevatedButton(
                    //       onPressed: () {},
                    //       style: ElevatedButton.styleFrom(
                    //           backgroundColor:
                    //               Colors.redAccent.withOpacity(0.1),
                    //           elevation: 0,
                    //           foregroundColor: Colors.red,
                    //           shape: const StadiumBorder(),
                    //           side: BorderSide.none),
                    //       child: const Text('tDelete'),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
