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

  final CollectionReference _postCollection =
      FirebaseFirestore.instance.collection('posts');

  final CollectionReference _reportsCollection =
      FirebaseFirestore.instance.collection('reports');

  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> createUser(
    String uid,
    String firstName,
    String lastName,
    String email,
    String username,
  ) async {
    try {
      final doesUsernameExist = await checkIfUsernameExists(username);
      if (doesUsernameExist) {
        throw Exception(
            "Username already exists. Please choose a different one.");
      }
      await _firestore.collection("users").doc(uid).set({
        "firstName": firstName.trim(),
        "lastName": lastName.trim(),
        "email": email.trim(),
        "username": username.trim(),
        "pengQuote": "",
        "myInterests": [],
        "profilePictureUrl": null,
        "friends": [],
        "pendingFriends": [],
        "isNewUser": true,
        "blockedUsers": [],
      });
      log("User created successfully for UID: $uid");
    } catch (e) {
      log("Failed to create user: $e");
      rethrow;
    }
  }

  Future<bool> checkIfNewUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }
      return userDoc.data()?['isNewUser'] ?? false;
    } catch (e) {
      log("Failed to check new user status: $e");
      rethrow;
    }
  }

  Future<void> setNewUserFlag(String userId, bool isNewUser) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isNewUser': isNewUser,
      });
      log("Updated isNewUser flag to $isNewUser for user: $userId");
    } catch (e) {
      log("Failed to update isNewUser flag: $e");
      rethrow;
    }
  }

  Future<bool> checkIfUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Failed to check if username exists: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = await getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      if (_userCache.containsKey(user.uid)) {
        return _userCache[user.uid];
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) throw Exception("User document does not exist.");

      final data = userDoc.data() as Map<String, dynamic>;
      _userCache[user.uid] = data;
      return data;
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
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      log("Failed to fetch user details: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserDataForUserId(String userId) async {
    try {
      if (_userCache.containsKey(userId)) {
        return _userCache[userId];
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist for user ID: $userId");
      }

      final userData = userDoc.data();
      if (userData != null) {
        _userCache[userId] = userData;
      }

      return userData;
    } catch (e) {
      log("Failed to fetch user data for userId $userId: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersExcept(
      String currentUserId) async {
    try {
      final currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (!currentUserDoc.exists) {
        throw Exception("Current user document does not exist.");
      }

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final List<String> friends =
          List<String>.from(currentUserData['friends'] ?? []);
      final List<String> pendingFriends =
          List<String>.from(currentUserData['pendingFriends'] ?? []);
      final List<String> friendRequests =
          List<String>.from(currentUserData['friendRequests'] ?? []);

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

      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friends': FieldValue.arrayRemove([friendUserId]),
      });

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

      batch.update(_firestore.collection('users').doc(currentUserId), {
        'friends': FieldValue.arrayUnion([requesterId]),
        'friendRequests': FieldValue.arrayRemove([requesterId]),
      });

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
      final currentUserDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get(GetOptions(source: Source.cache));

      final profileUserDoc = await _firestore
          .collection('users')
          .doc(profileUserId)
          .get(GetOptions(source: Source.cache));

      if (!currentUserDoc.exists || !profileUserDoc.exists) {
        throw Exception("One or both user documents do not exist.");
      }

      final friends =
          List<String>.from(currentUserDoc.data()?['friends'] ?? []);
      final sentRequests =
          List<String>.from(profileUserDoc.data()?['friendRequests'] ?? []);
      final incomingRequests =
          List<String>.from(currentUserDoc.data()?['friendRequests'] ?? []);

      if (friends.contains(profileUserId)) {
        return 'friends';
      } else if (sentRequests.contains(currentUserId)) {
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

      final cachedData = _userCache[user.uid] ?? {};
      _userCache[user.uid] = {...cachedData, ...updates};

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

      if (_userCache.containsKey(user.uid)) {
        _userCache[user.uid]!['profilePictureUrl'] = downloadUrl;
      }

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

      if (_userCache.containsKey(user.uid)) {
        _userCache[user.uid]!['profilePictureUrl'] = null;
      }

      log("Profile picture reset to default.");
    } catch (e) {
      log("Failed to reset profile picture: $e");
      throw Exception("Failed to reset profile picture: $e");
    }
  }

  Future<String?> getProfilePictureUrl(String userId) async {
    try {
      if (_userCache.containsKey(userId) &&
          _userCache[userId]!['profilePictureUrl'] != null) {
        return _userCache[userId]!['profilePictureUrl'] as String;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) throw Exception("User document does not exist.");

      final url = userDoc.data()?['profilePictureUrl'] as String?;
      if (url != null) {
        _userCache[userId] ??= {};
        _userCache[userId]!['profilePictureUrl'] = url;
      }
      return url;
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

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(chatRoomRef);

        if (!snapshot.exists) {
          transaction.set(chatRoomRef, {
            'users': [user1, user2],
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });

      return chatRoomId;
    } catch (e) {
      log("Failed to create or get chatroom: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> sendMessage(
      String chatRoomId, String senderId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      final messageData = {
        'senderId': senderId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'delivered',
      };

      final chatRoomRef = _firestore.collection('chatrooms').doc(chatRoomId);

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          chatRoomRef.collection('messages').doc(),
          messageData,
        );

        transaction.update(chatRoomRef, {
          'lastMessage': text.trim(),
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });
      });

      log("Message sent to chatroom $chatRoomId");
    } catch (e) {
      log("Failed to send message: ${e.toString()}");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getChatroomDetails(String chatRoomId) async {
    try {
      final chatRoomDoc =
          await _firestore.collection('chatrooms').doc(chatRoomId).get();
      if (!chatRoomDoc.exists) {
        return null;
      }
      return chatRoomDoc.data();
    } catch (e) {
      log("Failed to get chatroom details for $chatRoomId: $e");
      return null;
    }
  }

  Future<void> updateLastOpened(String chatRoomId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("No logged-in user.");
      }

      final chatRoomRef = _firestore.collection('chatrooms').doc(chatRoomId);

      await _firestore.runTransaction((transaction) async {
        final chatRoomSnapshot = await transaction.get(chatRoomRef);

        if (!chatRoomSnapshot.exists) {
          throw Exception("Chatroom does not exist.");
        }

        transaction.update(chatRoomRef, {
          'lastOpened.$currentUserId': FieldValue.serverTimestamp(),
        });
      });

      log("Updated last opened for chatRoomId: $chatRoomId by user: $currentUserId");
    } catch (e) {
      log("Failed to update last opened: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> updateMessageStatus(
      String chatRoomId, String messageId, String status) async {
    try {
      await _firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'status': status});
      log("Updated message $messageId status to $status.");
    } catch (e) {
      log("Failed to update message status: $e");
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

  Future<List<Map<String, dynamic>>> getUnreadMessages(
      String chatRoomId, String userId) async {
    try {
      final chatRoomDoc =
          await _firestore.collection('chatrooms').doc(chatRoomId).get();
      if (!chatRoomDoc.exists) throw Exception("Chatroom does not exist.");

      final lastOpened = chatRoomDoc.data()?['lastOpened']?[userId];
      if (lastOpened == null) {
        log("No lastOpened timestamp found for user: $userId in chatroom: $chatRoomId");
        return [];
      }

      final messagesSnapshot = await _firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('timestamp', isGreaterThan: lastOpened)
          .orderBy('timestamp', descending: true)
          .get();

      return messagesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      log("Failed to fetch unread messages for user: $userId in chatroom: $chatRoomId. Error: $e");
      return [];
    }
  }

  Future<String> uploadPostToStorage(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${file.path.split('/').last}';
      final ref = _storage.ref().child('shows/$userId/$fileName');

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      log("File uploaded successfully. URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      log("Failed to upload file: $e");
      throw Exception("Failed to upload file: $e");
    }
  }

  Future<void> addPost(String userId, String mediaUrl, String type) async {
    try {
      await _postCollection.add({
        'userId': userId,
        'mediaUrl': mediaUrl,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
      log("Post added successfully for user: $userId");
    } catch (e) {
      log("Failed to add post: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _postCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = (data['timestamp'] as Timestamp).toDate();
            final isExpired = now.difference(timestamp).inHours >= 24;
            return {
              'postId': doc.id,
              ...data,
              'isExpired': isExpired,
            };
          })
          .where((post) => !post['isExpired'])
          .toList();
    } catch (e) {
      log("Failed to fetch user posts: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFriendsPosts(
      String currentUserId) async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist.");
      }

      final List<String> friends =
          List<String>.from(userDoc.data()?['friends'] ?? []);

      if (friends.isEmpty) {
        log("User has no friends.");
        return [];
      }

      final postsFuture = _firestore
          .collection('posts')
          .where('userId', whereIn: friends)
          .orderBy('timestamp', descending: true)
          .get();

      final friendsDocsFuture = _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friends)
          .get();

      final results = await Future.wait([postsFuture, friendsDocsFuture]);
      final postsSnapshot = results[0] as QuerySnapshot;
      final friendsDocsSnapshot = results[1] as QuerySnapshot;

      final friendsData = {
        for (var doc in friendsDocsSnapshot.docs)
          doc.id: doc.data() as Map<String, dynamic>
      };

      return postsSnapshot.docs.map((postDoc) {
        final postData = postDoc.data() as Map<String, dynamic>;
        final userId = postData['userId'];

        final userData = _userCache[userId] ?? friendsData[userId];

        if (userData != null && !_userCache.containsKey(userId)) {
          _userCache[userId] = userData;
        }

        final userMap = userData;

        return {
          'userId': userId,
          'mediaUrl': postData['mediaUrl'],
          'type': postData['type'],
          'timestamp': postData['timestamp'],
          'firstName': userMap?['firstName'] ?? '',
          'lastName': userMap?['lastName'] ?? '',
          'username': userMap?['username'] ?? '',
          'profilePictureUrl': userMap?['profilePictureUrl'] ?? '',
        };
      }).toList();
    } catch (e) {
      log("Failed to fetch friends' posts: $e");
      return [];
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _postCollection.doc(postId).delete();
      log("Post deleted successfully: $postId");
    } catch (e) {
      log("Failed to delete post: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      log("Starting deletion for user: $userId");

      final userPostsSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      for (var postDoc in userPostsSnapshot.docs) {
        await postDoc.reference.delete();
        log("Deleted post doc: ${postDoc.id}");
      }
      log("Deleted all post docs for user: $userId");

      try {
        final userShowsRef = _storage.ref().child('shows/$userId');
        final listResult = await userShowsRef.listAll();

        for (var itemRef in listResult.items) {
          await itemRef.delete();
          log("Deleted show file: ${itemRef.name}");
        }

        await userShowsRef.delete();
        log("Deleted 'shows/$userId' folder in Storage.");
      } catch (e) {
        log("No 'shows/$userId' folder to delete or error: $e");
      }

      final profilePictureRef = _storage.ref().child('profilePictures/$userId');
      try {
        await profilePictureRef.delete();
        log("Deleted profile picture for user: $userId");
      } catch (e) {
        log("No profile picture to delete for user: $userId, or error: $e");
      }

      final allUsersSnapshot = await _firestore.collection('users').get();
      for (var doc in allUsersSnapshot.docs) {
        final data = doc.data();
        final friends = List<String>.from(data['friends'] ?? []);
        final pendingFriends = List<String>.from(data['pendingFriends'] ?? []);
        final friendRequests = List<String>.from(data['friendRequests'] ?? []);

        if (friends.contains(userId) ||
            pendingFriends.contains(userId) ||
            friendRequests.contains(userId)) {
          await doc.reference.update({
            'friends': FieldValue.arrayRemove([userId]),
            'pendingFriends': FieldValue.arrayRemove([userId]),
            'friendRequests': FieldValue.arrayRemove([userId]),
          });
          log("Removed user: $userId from doc: ${doc.id}");
        }
      }

      final chatroomsSnapshot = await _firestore
          .collection('chatrooms')
          .where('users', arrayContains: userId)
          .get();
      for (var chatDoc in chatroomsSnapshot.docs) {
        await chatDoc.reference.delete();
        log("Deleted chatroom: ${chatDoc.id} for user: $userId");
      }

      await _firestore.collection('users').doc(userId).delete();
      log("Deleted Firestore user doc for: $userId");

      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
        log("Deleted Auth record for user: $userId");
      }

      log("Deletion complete for user: $userId");
    } catch (e) {
      log("Failed to delete user: $userId. Error: $e");
      rethrow;
    }
  }

  Future<void> reportUser({
    required String reporterId,
    required String reporterUsername,
    required String reportedId,
    required String reportedUsername,
    required String reportedEmail,
    required String reason,
  }) async {
    try {
      await _reportsCollection.add({
        'reporterId': reporterId,
        'reporterUsername': reporterUsername,
        'reportedId': reportedId,
        'reportedUsername': reportedUsername,
        'reportedEmail': reportedEmail,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      log("Report added successfully.");
    } catch (e) {
      log("Failed to add report: $e");
      rethrow;
    }
  }

  Future<void> blockUser(String currentUserId, String userToBlock) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([userToBlock]),
      });
      log("$userToBlock blocked by $currentUserId.");
    } catch (e) {
      log("Failed to block user: $e");
      rethrow;
    }
  }

  Future<void> unblockUser(String currentUserId, String userToUnblock) async {
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([userToUnblock]),
      });
      log("$userToUnblock unblocked by $currentUserId.");
    } catch (e) {
      log("Failed to unblock user: $e");
      rethrow;
    }
  }
}
