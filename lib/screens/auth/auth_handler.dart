import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kary_win/routing/routing.dart';
import 'package:kary_win/screens/driver_interface/super_user_home.dart';

Future<User?> login(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } catch (e) {
    print('Error logging in: $e');
    return null;
  }
}

Future<String?> fetchUserType(String uid) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      return userDoc['Role'];
    } else {
      throw Exception('No such user!');
    }
  } catch (e) {
    print('Error fetching user type: $e');
    return null;
  }
}

void redirectToInterface(BuildContext context, String userType) {
  var _isloading = true;
  if (userType == 'SuperUser') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DriverRouteScreen()),
    ); 
  }
  if (userType == 'User') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Routing()),
    ); 
  }
}

Future<void> handleLogin(
    BuildContext context, String email, String password) async {
  User? user = await login(email, password);
  if (user != null) {
    String? userType = await fetchUserType(user.uid);
    if (userType != null) {
      redirectToInterface(context, userType);
    } else {
      print('User type is null');
    }
  } else {
    print('Login failed');
  }
}

String? validateEmail(String? email) {
  RegExp emailRegex = RegExp(r'^[\w\.-]+@[\w-]+\.\w{2,3}(\.\w{2,3})?$');
  final isEmailValid = emailRegex.hasMatch(email ?? '');
  if (!isEmailValid) {
    return 'Enter a Valid Email';
  }
  return null;
}
