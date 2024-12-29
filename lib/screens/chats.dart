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
  final int _pageSize = 7;
  int _currentIndex = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFriends();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoading &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadMoreFriends();
    }
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
      setState(() {
        _isLoading = true;
      });

      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No logged-in user found.");
      }

      final userData =
          await _databaseService.getUserDataForUserId(currentUser.uid);
      if (userData == null || !userData.containsKey('friends')) {
        throw Exception("Failed to retrieve friends list.");
      }

      _friendIds = List<String>.from(userData['friends']);
      _friends.clear();
      _currentIndex = 0;

      await _loadMoreFriends();
    } catch (e) {
      debugPrint("Error loading friends: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFriends() async {
    if (_currentIndex >= _friendIds.length) return;

    setState(() => _isLoading = true);

    final endIndex = (_currentIndex + _pageSize).clamp(0, _friendIds.length);
    final pageFriendIds = _friendIds.sublist(_currentIndex, endIndex);

    final currentUser = await _databaseService.getCurrentUser();
    if (currentUser == null) return;

    final friendsData = await _databaseService.getUsersByIds(pageFriendIds);

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

      if (lastMessageDoc != null) {
        final lastMessageData = lastMessageDoc.data();

        friend['lastMessage'] = lastMessageData['text'] ?? 'No messages yet';
        friend['lastInteraction'] = lastMessageData['timestamp'] != null
            ? (lastMessageData['timestamp'] as Timestamp).toDate()
            : null;
      } else {
        friend['lastMessage'] = 'No messages yet';
        friend['lastInteraction'] = null;
      }

      final chatRoomData =
          await _databaseService.getChatroomDetails(chatRoomId);
      if (chatRoomData != null) {
        final lastOpenedMap =
            chatRoomData['lastOpened'] as Map<String, dynamic>?;

        final lastOpenedValue =
            lastOpenedMap != null ? lastOpenedMap[currentUser.uid] : null;

        if (lastOpenedValue != null && friend['lastInteraction'] != null) {
          final lastInteractionDate = friend['lastInteraction'] as DateTime;
          final lastOpenedTimestamp = lastOpenedValue as Timestamp;
          final lastOpenedDate = lastOpenedTimestamp.toDate();

          friend['hasNewMessage'] = lastInteractionDate.isAfter(lastOpenedDate);
        } else {
          friend['hasNewMessage'] = (friend['lastInteraction'] != null);
        }
      } else {
        friend['hasNewMessage'] = (friend['lastInteraction'] != null);
      }
    }

    friendsData.sort((a, b) => (b['lastInteraction'] ??
            DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(
            a['lastInteraction'] ?? DateTime.fromMillisecondsSinceEpoch(0)));

    setState(() {
      _friends.addAll(friendsData);
      _isLoading = false;
    });

    _currentIndex = endIndex;
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
