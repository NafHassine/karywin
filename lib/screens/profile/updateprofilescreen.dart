import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kary_win/screens/profile/constants.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:kary_win/screens/profile/componantes.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  late User? _currentUser;
  Map<String, dynamic>? _userData;
  String? _imageUrl;
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _getUserData();
  }

  Future<void> _getUserData() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _userData = userSnapshot.data() as Map<String, dynamic>?;
          _imageUrl = userSnapshot['imageUrl'];
          _usernameController.text = _userData?['username'] ?? 'Loading...';
          _emailController.text = _userData?['email'] ?? 'Loading...';
          _phoneController.text = _userData?['phone'] ?? 'Loading...';
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              //--Image Holder
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: _imageUrl != null
                      ? Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        )
                      : Image.asset(
                          'assets/images/profile_image.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 50),

              // -- Form Fields
              Form(
                child: Column(
                  children: [
                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: tUserName,
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: tEmail,
                        prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Phone number field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: tPhoneNo,
                        prefixIcon: Icon(LineAwesomeIcons.phone),
                      ),
                    ),
                    const SizedBox(height: tFormHeight - 20),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
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
                    TextFormField(
                      controller: _repeatPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Repeat password",
                        prefixIcon: const Icon(Icons.fingerprint),
                        suffixIcon: IconButton(
                          icon: const Icon(LineAwesomeIcons.eye_slash),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: tFormHeight),
                    const SizedBox(
                      height: 20,
                    ),
                    // Edit Profile button
                    GestureDetector(
                      onTap: () async {
                        // Check if email field is not empty and has changed
                        if (_emailController.text.isNotEmpty) {
                          await updateEmail(_emailController.text);
                        }
                        // Check if password field is not empty and has changed
                        if (_passwordController.text.isNotEmpty &&
                            _repeatPasswordController.text.isNotEmpty &&
                            _passwordController.text ==
                                _repeatPasswordController.text) {
                          await updatePassword(_passwordController.text,
                              _repeatPasswordController.text);
                        }
                        // Check if phone field is not empty and has changed
                        if (_phoneController.text.isNotEmpty) {
                          await updatePhoneNumber(_phoneController.text);
                        }
                        if (_usernameController.text.isNotEmpty) {
                          await updateUsername(_usernameController.text);
                        }
                        Navigator.pop(context, 'updated');
                      },
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
