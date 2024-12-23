import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/lists.dart';
import 'package:ping_peng/screens/account.dart';

class Chatroom extends StatefulWidget {
  final String username;
  final String chatRoomId;
  final String friendProfilePictureUrl;
  final String friendUserId;

  const Chatroom({
    super.key,
    required this.username,
    required this.chatRoomId,
    required this.friendProfilePictureUrl,
    required this.friendUserId,
  });

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();
  bool _iceBreakersVisible = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _updateLastOpened();
    _markMessagesAsSeen();
  }

  Future<void> _initializeUser() async {
    final currentUser = await _databaseService.getCurrentUser();
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.orange),
        backgroundColor: Colors.black,
        title: Text(
          widget.username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Account(userId: widget.friendUserId),
                ),
              );
            },
            child: CircleAvatar(
              radius: 20,
              backgroundImage: widget.friendProfilePictureUrl.isNotEmpty
                  ? NetworkImage(widget.friendProfilePictureUrl)
                  : null,
              backgroundColor: Colors.grey,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.black,
      body: chatroomScreen(),
    );
  }

  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseService.getMessages(widget.chatRoomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text(
              'Loading Chats...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          );
        }

        _markMessagesAsSeen();

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMyMessage = message['senderId'] == _currentUserId;
            return _messageBubble(message['text'] ?? '', isMyMessage);
          },
        );
      },
    );
  }

  Widget _messageBubble(String message, bool isMyMessage) {
    final alignment =
        isMyMessage ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMyMessage ? Colors.cyan[100] : Colors.white;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          softWrap: true,
        ),
      ),
    );
  }

  Widget _messageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/icons/ping.png',
                    height: 50,
                    width: 45,
                  ),
                  onPressed: () {
                    setState(() {
                      _iceBreakersVisible = !_iceBreakersVisible;
                    });
                  },
                ),
                Expanded(
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.orange, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: _messageController,
                      cursorColor: Colors.orange,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.orange, size: 30),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
            const SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  Widget _iceBreakersMenu() {
    final List<String> icebreakers = IceBreakers().getIcebreakers();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: icebreakers.asMap().entries.map((entry) {
          final iceBreaker = entry.value;

          return GestureDetector(
            onTap: () {
              _sendMessage(iceBreaker);
              setState(() {
                _iceBreakersVisible = false;
              });
            },
            child: Center(
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        iceBreaker,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Sends a [message] from the current user to the Firestore chatroom.
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _currentUserId == null) return;

    try {
      await _databaseService.sendMessage(
        widget.chatRoomId,
        _currentUserId!,
        message.trim(),
      );
      _messageController.clear();
    } catch (e) {
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to send message.",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }
  }

  Future<void> _updateLastOpened() async {
    if (_currentUserId == null) return;
    try {
      await _databaseService.updateLastOpened(widget.chatRoomId);
      debugPrint(
        "Updated last opened for ${widget.chatRoomId} by user $_currentUserId.",
      );
    } catch (e) {
      debugPrint("Failed to update last opened: $e");
    }
  }

  Future<void> _markMessagesAsSeen() async {
    if (_currentUserId == null) return;
    try {
      final unreadMessages = await _databaseService.getUnreadMessages(
        widget.chatRoomId,
        _currentUserId!,
      );
      for (var message in unreadMessages) {
        await _databaseService.updateMessageStatus(
          widget.chatRoomId,
          message['id'],
          'seen',
        );
      }
      debugPrint("Marked messages as seen.");
    } catch (e) {
      debugPrint("Failed to mark messages as seen: $e");
    }
  }

  Widget chatroomScreen() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              _iceBreakersVisible ? _iceBreakersMenu() : _messageList(),
            ],
          ),
        ),
        _messageInput(),
      ],
    );
  }
}
