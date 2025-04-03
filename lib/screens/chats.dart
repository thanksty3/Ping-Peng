import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/utils.dart';
import 'package:ping_peng/screens/chatroom.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final DatabaseService _databaseService = DatabaseService();
  final List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;
  List<String> _friendIds = [];
  final ScrollController _scrollController = ScrollController();
  final Map<String, StreamSubscription<DocumentSnapshot>> _friendSubscriptions =
      {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _friendSubscriptions.forEach((_, subscription) {
      subscription.cancel();
    });
    _friendSubscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatsNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading && _friends.isEmpty
          ? const Center(
              child: Text(
                'Loading Chats...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : chatsScreen(),
      bottomNavigationBar: const ChatsNavBottomNavigationBar(),
    );
  }

  Future<void> _loadFriends() async {
    try {
      setState(() => _isLoading = true);

      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No logged-in user found.");

      final userData =
          await _databaseService.getUserDataForUserId(currentUser.uid);
      if (userData == null) throw Exception("Failed to retrieve user data.");

      final friendIds = List<String>.from(userData['friends'] ?? []);
      final blockedUsers = List<String>.from(userData['blockedUsers'] ?? []);
      final unblockedFriendIds =
          friendIds.where((id) => !blockedUsers.contains(id)).toList();

      _friendIds = unblockedFriendIds;
      _friends.clear();

      final friendsData = await _databaseService.getUsersByIds(_friendIds);

      for (var friend in friendsData) {
        final chatRoomId = await _databaseService.createOrGetChatroom(
            currentUser.uid, friend['userId']);

        friend['chatRoomId'] = chatRoomId;
        friend['hasNewMessage'] = false;

        _friendSubscriptions[friend['userId']] = FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(chatRoomId)
            .snapshots()
            .listen((doc) {
          if (doc.exists) {
            final data = doc.data()!;
            final lastMessageTimestamp =
                data['lastMessageTimestamp'] as Timestamp?;
            final lastOpened =
                data['lastOpened']?[currentUser.uid] as Timestamp?;
            final lastMessageText = data['lastMessage'] ?? 'No messages yet';

            friend['lastMessage'] = lastMessageText;

            friend['hasNewMessage'] = lastMessageTimestamp != null &&
                (lastOpened == null ||
                    lastMessageTimestamp.toDate().isAfter(lastOpened.toDate()));

            setState(() {});
          }
        });
      }

      setState(() {
        _friends.addAll(friendsData);
      });
    } catch (e) {
      debugPrint("Error loading friends: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: Text("Failed to load chats: $e",
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLastOpened(String chatRoomId) async {
    try {
      await _databaseService.updateLastOpened(chatRoomId);
      debugPrint("Updated last opened for chatRoomId: $chatRoomId");
    } catch (e) {
      debugPrint("Failed to update lastOpened: $e");
    }
  }

  void _navigateToChatroom(Map<String, dynamic> friend) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No logged-in user found.");
      }

      final chatRoomId = friend['chatRoomId'] as String? ??
          await _databaseService.createOrGetChatroom(
            currentUser.uid,
            friend['userId'] ?? '',
          );

      await _updateLastOpened(chatRoomId);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Chatroom(
                  username: '@${friend['username']}',
                  chatRoomId: chatRoomId,
                  friendProfilePictureUrl: friend['profilePictureUrl'] ?? '',
                  friendUserId: friend['userId'] ?? '',
                ),
            fullscreenDialog: true),
      ).then((_) {
        _updateLastOpened(chatRoomId);
      });
    } catch (e) {
      debugPrint("Error navigating to chatroom: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            "Failed to open chatroom. Please try again.",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Widget chatsScreen() {
    if (_friends.isEmpty) {
      return const Center(
        child: Text(
          'No chats yet!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];

        return Material(
          color: Colors.black,
          child: InkWell(
            onTap: () => _navigateToChatroom(friend),
            splashColor: Colors.orange.withOpacity(0.2),
            highlightColor: Colors.orange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: friend['profilePictureUrl'] != null
                        ? NetworkImage(friend['profilePictureUrl'])
                        : const AssetImage('assets/images/Black_Peng.png')
                            as ImageProvider,
                    backgroundColor: Colors.black,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '@${friend['username']}',
                          style: const TextStyle(
                            fontFamily: 'Jua',
                            fontSize: 19,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${friend['firstName']} ${friend['lastName']}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          friend['lastMessage'] ?? 'No messages yet',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (friend['hasNewMessage']) ...[
                    const SizedBox(width: 10),
                    const CircleAvatar(
                      radius: 5,
                      backgroundColor: Colors.orange,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
