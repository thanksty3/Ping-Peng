import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get the currently authenticated user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Create a new user document in Firestore
  Future<void> createUser(String uid, String firstName, String lastName,
      String email, String username) async {
    try {
      await _firestore.collection("users").doc(uid).set({
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "email": email.trim(),
        "username": username.trim(),
        "pengQuote": "",
        "myInterests": [],
        "profilePictureUrl": null,
        "friends": [],
      });
      log("User created successfully for UID: $uid");
    } catch (e) {
      log("Failed to create user: $e");
      rethrow;
    }
  }

  // Fetch the current user's data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw Exception("User document does not exist.");

      return userDoc.data();
    } catch (e) {
      log("Failed to fetch user data: $e");
      return null;
    }
  }

  // Update the user's profile data
  Future<void> updateUserData(
      {String? pengQuote, List<String>? myInterests}) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      final updates = <String, dynamic>{};
      if (pengQuote != null) updates['pengQuote'] = pengQuote;
      if (myInterests != null) updates['myInterests'] = myInterests;

      await _firestore.collection('users').doc(user.uid).update(updates);
      log("User data updated successfully.");
    } catch (e) {
      log("Failed to update user data: $e");
      rethrow;
    }
  }

  // Uploads image to Firebase Storage and stores the download URL in Firestore
  Future<void> uploadAndSaveProfilePicture(File image) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      // Upload the image to Firebase Storage
      final ref = _storage.ref().child('profilePictures/${user.uid}');
      await ref.putFile(image);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      // Save the download URL in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'profilePictureUrl': downloadUrl});

      log("Profile picture uploaded and saved successfully.");
    } catch (e) {
      log("Failed to upload profile picture: $e");
      rethrow;
    }
  }

  // Fetches the profile picture URL from Firestore
  Future<String?> fetchProfilePicture() async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        return doc.data()?['profilePictureUrl'] as String?;
      }
      return null;
    } catch (e) {
      log("Failed to fetch profile picture: $e");
      return null;
    }
  }

  // Reset the user's profile picture to default
  Future<void> resetProfilePicture() async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': null,
      });
      log("Profile picture reset to default.");
    } catch (e) {
      log("Failed to reset profile picture: $e");
      rethrow;
    }
  }

  // Search for users by username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'profilePictureUrl': data['profilePictureUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      log("Failed to search users: $e");
      return [];
    }
  }
}
