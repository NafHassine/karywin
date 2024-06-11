import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kary_win/screens/auth/login.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:kary_win/screens/profile/profile_menu.dart';
import 'package:kary_win/screens/profile/updateprofilescreen.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  late User? _currentUser;
  Map<String, dynamic>? _userData;
  File? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _getUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getUserData();
  }

  void logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => NewLoginPage()));
    } catch (e) {
      print("Error: $e");
    }
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
        });
        if (_userData != null && _userData!.containsKey('imageUrl')) {
          String userId = _currentUser!.uid;
          String imagePath = 'profile_images/$userId/profile.png';

          // Load image from Firebase Storage using the constructed path
          firebase_storage.Reference ref =
              firebase_storage.FirebaseStorage.instance.ref(imagePath);
          String downloadURL = await ref.getDownloadURL();
          setState(() {
            _image = File(downloadURL);
          });
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error fetching user data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
        _image = File(pickedFile.path);
      });

      String userId = _currentUser!.uid;

      // Upload image to Firebase Storage under a folder with user's ID
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(userId)
          .child('profile.jpg');

      try {
        await ref.putFile(_image!);
      } catch (e) {
        print('Error uploading image: $e');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      String downloadURL = await ref.getDownloadURL();

      // Update user document with the image URL
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      try {
        await userRef.set({
          'imageUrl': downloadURL,
        }, SetOptions(merge: true));
        setState(() {
          _isLoading = false;
        }); // Merge the new field with existing data
      } catch (e) {
        print('Error updating user document: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String tProfileImage =
        _userData?['imageUrl'] ?? 'assets/images/profile_image.png';
    String tProfilename = _userData?['username'] ?? 'Loading...';
    String tProfilemail = _userData?['email'] ?? 'Loading...';
    String tProfilephone = "+216 " + (_userData?['phone'] ?? 'Loading...');
    String tEditProfile = 'Edit Profile';

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover)
                          : _userData != null && _userData!['imageUrl'] != null
                              ? Image.network(
                                  tProfileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading image: $error');
                                    return Image.asset(
                                        'assets/images/profile_image.png');
                                  },
                                )
                              : Image.asset('assets/images/profile_image.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromRGBO(143, 148, 251, 1),
                                Color.fromRGBO(143, 148, 251, .6),
                              ],
                            ),
                          ),
                          child: const Icon(
                            LineAwesomeIcons.alternate_pencil,
                            color: Colors.black,
                            size: 20,
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(tProfilename, style: Theme.of(context).textTheme.titleLarge),
              Text(tProfilemail, style: Theme.of(context).textTheme.bodyMedium),
              Text(tProfilephone,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              GestureDetector(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Await result from UpdateProfileScreen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UpdateProfileScreen(),
                        ),
                      );
                      // Check if result is 'updated' and refresh user data
                      if (result == 'updated') {
                        _getUserData();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.transparent),
                      ),
                      elevation: 0,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            tEditProfile,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: "Settings",
                icon: LineAwesomeIcons.cog,
                onPress: () {},
              ),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: "Information",
                icon: LineAwesomeIcons.info,
                onPress: () {},
              ),
              ProfileMenuWidget(
                  title: "Logout",
                  icon: LineAwesomeIcons.alternate_sign_out,
                  textColor: Colors.red,
                  endIcon: false,
                  onPress: logout),
            ],
          ),
        ),
      ),
    );
  }
}
