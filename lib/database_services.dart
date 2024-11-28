// ignore_for_file: unnecessary_string_escapes

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
        "pendingFriends": []
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
      // Fetch current user's data for filtering
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!currentUserDoc.exists) {
        throw Exception("Current user document does not exist.");
      }

      final currentUserData = currentUserDoc.data()!;
      final List<String> friends =
          List<String>.from(currentUserData['friends'] ?? []);
      final List<String> pendingFriends =
          List<String>.from(currentUserData['pendingFriends'] ?? []);
      final List<String> friendRequests =
          List<String>.from(currentUserData['friendRequests'] ?? []);

      // Combine all users to exclude
      final Set<String> excludedUserIds = {
        currentUserId,
        ...friends,
        ...pendingFriends,
        ...friendRequests,
      };

      final querySnapshot = await _firestore.collection('users').get();

      final filteredUsers = querySnapshot.docs.where((doc) {
        final userId = doc.id;
        return !excludedUserIds.contains(userId);
      }).map((doc) {
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

      return filteredUsers;
    } catch (e) {
      log("Failed to fetch filtered users: $e");
      return [];
    }
  }

  Future<void> addFriend(String currentUserId, String friendUserId) async {
    try {
      await _firestore.collection('users').doc(friendUserId).update({
        'friendRequests': FieldValue.arrayUnion([currentUserId]),
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
      final profileUserData = profileUserDoc.data()!;

      final friends = List<String>.from(currentUserData['friends'] ?? []);
      final sentRequests =
          List<String>.from(profileUserData['friendRequests'] ?? []);
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

  Future<void> uploadAndSaveProfilePicture(File image) async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      final ref = _storage.ref().child('profilePictures/${user.uid}');
      log("Uploading file to: profilePictures/${user.uid}");

      await ref.putFile(image);
      log("Image uploaded successfully.");

      final downloadUrl = await ref.getDownloadURL();
      log("Download URL obtained: $downloadUrl");

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

  Future<String> createOrGetChatroom(String user1, String user2) async {
    try {
      final chatRoomId =
          (user1.compareTo(user2) < 0) ? '$user1\_$user2' : '$user2\_$user1';
      final chatRoomRef = _firestore.collection('chatrooms').doc(chatRoomId);

      final chatRoomSnapshot = await chatRoomRef.get();
      if (!chatRoomSnapshot.exists) {
        // Create chatroom if it doesn't exist
        await chatRoomRef.set({
          'users': [user1, user2],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return chatRoomId;
    } catch (e) {
      log("Failed to create or get chatroom: $e");
      rethrow;
    }
  }

  Future<void> sendMessage(
      String chatRoomId, String senderId, String text) async {
    try {
      final messageData = {
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);
      log("Message sent to chatroom $chatRoomId");
    } catch (e) {
      log("Failed to send message: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    try {
      return _firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      log("Failed to fetch messages: $e");
      rethrow;
    }
  }
}
