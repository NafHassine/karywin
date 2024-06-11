import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateEmail(String newEmail) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail});
    } else {
      print("User is null");
    }
  } catch (e) {
    print("Failed to update email: $e");
  }
}

Future<void> updatePassword(String newPassword, String repeatPassword) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      print("User is null");
    }
  } catch (e) {
    print("Failed to update password: $e");
  }
}

Future<void> updatePhoneNumber(String newPhoneNumber) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'phone': newPhoneNumber});
    } else {
      print("User is null");
    }
  } catch (e) {
    print("Failed to update phone number: $e");
  }
}

Future<void> updateUsername(String newUsername) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});
    } else {
      print("User is null");
    }
  } catch (e) {
    print("Failed to update username: $e");
  }
}
