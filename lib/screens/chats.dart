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
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatsNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.orange,
            ))
          : chatsScreen(),
      bottomNavigationBar: const ChatsNavBottomNavigationBar(),
    );
  }

  Future<void> _loadFriends() async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No logged-in user found.");
      }

      final userData =
          await _databaseService.getUserDataForUserId(currentUser.uid);
      if (userData == null || !userData.containsKey('friends')) {
        throw Exception("Failed to retrieve friends list.");
      }

      final friendIds = List<String>.from(userData['friends']);
      final friendsData = await _databaseService.getUsersByIds(friendIds);

      for (var friend in friendsData) {
        final chatRoomId = await _databaseService.createOrGetChatroom(
          currentUser.uid,
          friend['userId'],
        );

        final lastMessageSnapshot = await FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(chatRoomId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        final lastMessageDoc = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first
            : null;

        friend['lastMessage'] = lastMessageDoc != null
            ? lastMessageDoc['text'] ?? 'No messages yet'
            : 'No messages yet';

        friend['lastInteraction'] = lastMessageDoc != null
            ? lastMessageDoc['timestamp']?.toDate()
            : null;

        final chatRoomData =
            await _databaseService.getChatroomDetails(chatRoomId);
        final lastOpened = chatRoomData?['lastOpened']?[currentUser.uid];
        friend['hasNewMessage'] = lastMessageDoc != null &&
            lastMessageDoc['timestamp'] != null &&
            (lastOpened == null ||
                lastMessageDoc['timestamp']
                    .toDate()
                    .isAfter(lastOpened.toDate()));
      }

      friendsData.sort((a, b) => (b['lastInteraction'] ??
              DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(
              a['lastInteraction'] ?? DateTime.fromMillisecondsSinceEpoch(0)));

      setState(() {
        _friends = friendsData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading friends: $e");
      setState(() {
        _isLoading = false;
      });
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

      final chatRoomId = await _databaseService.createOrGetChatroom(
        currentUser.uid,
        friend['userId'] ?? '',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chatroom(
            username: '@${friend['username']}',
            chatRoomId: chatRoomId,
            friendProfilePictureUrl: friend['profilePictureUrl'] ?? '',
            friendUserId: friend['userId'] ?? '',
          ),
        ),
      ).then((_) {
        _updateLastOpened(chatRoomId);
        _loadFriends();
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
    return ListView.builder(
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return GestureDetector(
          onTap: () => _navigateToChatroom(friend),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: friend['profilePictureUrl'] != null
                      ? NetworkImage(friend['profilePictureUrl'])
                      : null,
                  backgroundColor: Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${friend['firstName']} ${friend['lastName']}',
                        style: const TextStyle(
                          fontFamily: 'Jua',
                          fontSize: 19,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '@${friend['username']}',
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
                if (friend['hasNewMessage'] == true) ...[
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.orange,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
