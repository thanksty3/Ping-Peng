import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        "friends": []
      });
      log("User created successfully for UID: $uid");
    } catch (e) {
      log("Failed to create user: $e");
      rethrow; // Propagate the error for the caller to handle
    }
  }

  // Fetch current user's data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception("No user is logged in.");

      String uid = user.uid;

      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) throw Exception("User document does not exist.");

      Map<String, dynamic>? data = userDoc.data();
      if (data == null) throw Exception("User data is null.");

      return {
        'firstName': data['firstName'] ?? '',
        'lastName': data['lastName'] ?? '',
        'username': data['username'] ?? '',
        'pengQuote': data['pengQuote'] ?? '',
        'myInterests': List<String>.from(data['myInterests'] ?? []),
      };
    } catch (e) {
      log("Failed to fetch user data: $e");
      return null;
    }
  }

  // Get the profile picture URL from Firebase Storage
  Future<String> getProfilePictureUrl(String uid) async {
    try {
      String fileName = 'profilePictures/$uid';
      Reference ref = _storage.ref().child(fileName);
      return await ref.getDownloadURL();
    } catch (e) {
      log("Failed to get profile picture URL for UID: $uid, Error: $e");
      return '';
    }
  }

  //Read and log all users
  Future<void> readUsers() async {
    try {
      final data = await _firestore.collection("users").get();
      for (var doc in data.docs) {
        log("User: ${doc.data()}");
      }
    } catch (e) {
      log("Failed to read users: $e");
    }
  }

  //Add or remove a friend
  Future<void> updateFriends(
      String currentUserId, String friendUserId, bool add) async {
    String action = add ? "Adding" : "Removing";
    try {
      log("$action friend: $friendUserId for user: $currentUserId");

      await _firestore.collection("users").doc(currentUserId).update({
        'friends': add
            ? FieldValue.arrayUnion([friendUserId])
            : FieldValue.arrayRemove([friendUserId])
      });

      await _firestore.collection("users").doc(friendUserId).update({
        'friends': add
            ? FieldValue.arrayUnion([currentUserId])
            : FieldValue.arrayRemove([currentUserId])
      });

      log("$action friend successful");
    } catch (e) {
      log("Failed to $action friend: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: 'query\uf8ff')
          .get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'profilePictureUrl': data['prodilePictireUrl'] ?? ''
        };
      }).toList();
    } catch (e) {
      log("Failed to search users: $e");
      return [];
    }
  }
}
