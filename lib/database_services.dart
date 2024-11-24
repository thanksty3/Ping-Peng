import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

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

  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> userIds) async {
    try {
      final userDocs = await Future.wait(
        userIds
            .map((userId) => _firestore.collection('users').doc(userId).get()),
      );
      return userDocs
          .where((doc) => doc.exists)
          .map((doc) => {
                'userId': doc.id,
                ...doc.data()!,
              })
          .toList();
    } catch (e) {
      log("Failed to fetch user details: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserDataForUserId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist for user ID: $userId");
      }

      return userDoc.data();
    } catch (e) {
      log("Failed to fetch user data for userId $userId: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersExcept(
      String currentUserId) async {
    try {
      final querySnapshot = await _firestore.collection('users').get();

      return querySnapshot.docs
          .where((doc) => doc.id != currentUserId) // Exclude the logged-in user
          .map((doc) {
        final data = doc.data();
        return {
          'userId': doc.id,
          'username': data['username'] ?? '',
          'firstName': data['firstName'] ?? '',
          'lastName': data['lastName'] ?? '',
          'pengQuote': data['pengQuote'] ?? '',
          'myInterests': data['myInterests'] ?? [],
          'profilePictureUrl': data['profilePictureUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      log("Failed to fetch users: $e");
      return [];
    }
  }

  Future<void> addFriend(String currentUserId, String friendUserId) async {
    try {
      // Add friend to current user's friend list
      await _firestore.collection('users').doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([friendUserId]),
      });

      // Add current user to the friend's friend list
      await _firestore.collection('users').doc(friendUserId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      log("Friend added successfully.");
    } catch (e) {
      log("Failed to add friend: $e");
      rethrow;
    }
  }

  Future<void> removeFriend(String currentUserId, String friendUserId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Remove friend from current user's friend list
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

      // Remove current user from the friend's friend list
      batch.update(_firestore.collection('users').doc(friendUserId), {
        'friends': FieldValue.arrayRemove([currentUserId]),
      });

      await batch.commit();
      log("Friend removed successfully.");
    } catch (e) {
      log("Failed to remove friend: $e");
      rethrow;
    }
  }

  Future<List<String>> getFriendRequests(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return List<String>.from(userDoc.data()?['friendRequests'] ?? []);
      }
      return [];
    } catch (e) {
      log("Failed to fetch friend requests: $e");
      return [];
    }
  }

  Future<void> acceptFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Add requester to current user's friends
      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });

      // Add current user to requester's friends
      batch.update(_firestore.collection('users').doc(requesterId), {
        'friends': FieldValue.arrayUnion([currentUserId]),
      });

      await batch.commit();
      log("Friend request accepted successfully.");
    } catch (e) {
      log("Failed to accept friend request: $e");
      rethrow;
    }
  }

  Future<void> denyFriendRequest(
      String currentUserId, String requesterId) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });
      log("Friend request denied successfully.");
    } catch (e) {
      log("Failed to deny friend request: $e");
      rethrow;
    }
  }

  Future<String> getFriendStatus(
      String currentUserId, String profileUserId) async {
    try {
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final profileUserDoc =
          await _firestore.collection('users').doc(profileUserId).get();

      if (!currentUserDoc.exists || !profileUserDoc.exists) {
        throw Exception("One or both user documents do not exist.");
      }

      final currentUserData = currentUserDoc.data()!;

      final friends = List<String>.from(currentUserData['friends'] ?? []);
      final sentRequests =
          List<String>.from(currentUserData['sentRequests'] ?? []);
      final incomingRequests =
          List<String>.from(currentUserData['friendRequests'] ?? []);

      if (friends.contains(profileUserId)) {
        return 'friends';
      } else if (sentRequests.contains(profileUserId)) {
        return 'pending';
      } else if (incomingRequests.contains(profileUserId)) {
        return 'add_back';
      } else {
        return 'add';
      }
    } catch (e) {
      log("Error determining friend status: $e");
      rethrow;
    }
  }

  Future<void> updateUserData({
    String? pengQuote,
    List<String>? myInterests,
  }) async {
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

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      // Firestore query for matching usernames
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username',
              isLessThanOrEqualTo: '$query\uf8ff') // Firestore range query
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
}
