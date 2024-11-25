import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/utils.dart';

import 'chatroom.dart';

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
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return GestureDetector(
                  onTap: () => _navigateToChatroom(friend),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: friend['profilePictureUrl'] != null
                              ? NetworkImage(friend['profilePictureUrl'])
                              : null,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Column(
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
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const ChatsNavBottomNavigationBar(),
    );
  }

  Future<void> _loadFriends() async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception("No logged-in user found.");
      }

      // Fetch the current user's friends
      final userData =
          await _databaseService.getUserDataForUserId(currentUser.uid);
      if (userData == null || !userData.containsKey('friends')) {
        throw Exception("Failed to retrieve friends list.");
      }

      final friendIds = List<String>.from(userData['friends']);
      final friendsData = await _databaseService.getUsersByIds(friendIds);

      // Sort friends by a mocked "lastInteraction" field
      // Replace "lastInteraction" with the actual logic if available
      friendsData.sort((a, b) =>
          (b['lastInteraction'] ?? 0).compareTo(a['lastInteraction'] ?? 0));

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

  void _navigateToChatroom(Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chatroom(), // Pass friend details
      ),
    );
  }
}
