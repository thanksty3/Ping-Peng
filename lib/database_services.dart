import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String firstName, String lastName,
      String email, String username) async {
    try {
      await _firestore.collection("users").doc(uid).set({
        "First Name": firstName.trim(),
        "Last Name": lastName.trim(),
        "email": email.trim(),
        "username": username.trim(),
      });
      log("User created successfully");
    } catch (e) {
      log("Error Creating user: $e");
    }
  }

  Future<void> updateQuote(String uid, String pengQuote) async {
    try {
      await _firestore
          .collection("users")
          .doc(uid)
          .set({"Peng Quote": pengQuote});
      log("Peng Quote Updated");
    } catch (e) {
      log("Failed Updating Peng Quote");
    }
  }

  Future<Map<String, dynamic>?> readUser(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection("users").doc(uid).get();
      if (docSnapshot.exists) {
        log("User data fetched successfully");
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        log("No user found with the given UID");
        return null;
      }
    } catch (e) {
      log("Error reading user data: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection("users").get();
      List<Map<String, dynamic>> users = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      log("Fetched all users successfully");
      return users;
    } catch (e) {
      log("Error fetching all users: $e");
      return [];
    }
  }
}
