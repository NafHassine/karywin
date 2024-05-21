import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kary_win/routing/routing.dart';
import 'package:kary_win/screens/super_user_home.dart';
import 'package:kary_win/screens/test.dart';

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
      return userDoc[
          'Role']; // Assuming 'userType' is a field in your Firestore document
    } else {
      throw Exception('No such user!');
    }
  } catch (e) {
    print('Error fetching user type: $e');
    return null;
  }
}

void redirectToInterface(BuildContext context, String userType) {
  if (userType == 'SuperUser') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DriverRouteScreen()),
    ); // Adjust the route name to your superuser interface
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Routing()),
    ); // Adjust the route name to your user interface
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
