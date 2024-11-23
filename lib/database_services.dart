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

  // Upload and save the profile picture to Firebase Storage and Firestore
  Future<void> uploadAndSaveProfilePicture(File image) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      // Reference to Firebase Storage
      final ref = _storage.ref().child('profilePictures/${user.uid}');
      log("Uploading file to: profilePictures/${user.uid}");

      // Upload the image to Firebase Storage
      await ref.putFile(image);
      log("Image uploaded successfully.");

      // Retrieve the download URL
      final downloadUrl = await ref.getDownloadURL();
      log("Download URL obtained: $downloadUrl");

      // Save the download URL to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': downloadUrl,
      });
      log("Profile picture URL saved in Firestore.");
    } catch (e) {
      log("Failed to upload and save profile picture: $e");
      throw Exception("Failed to upload and save profile picture: $e");
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
      throw Exception("Failed to reset profile picture: $e");
    }
  }

  // Get the profile picture URL for a specific user
  Future<String?> getProfilePictureUrl(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception("User document does not exist.");

      return userDoc.data()?['profilePictureUrl'];
    } catch (e) {
      log("Failed to retrieve profile picture URL: $e");
      return null;
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
