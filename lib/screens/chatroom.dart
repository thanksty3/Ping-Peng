import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_peng/lists.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _iceBreakersVisible = false;

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
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
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
      body: Column(
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
      ),
    );
  }

  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
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

        final messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMyMessage = message['senderId'] == _auth.currentUser?.uid;

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

    return Positioned(
      right: 50,
      top: 0,
      bottom: 60,
      child: SingleChildScrollView(
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
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.cyan[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          iceBreaker,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'text': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add(messageData);

      _messageController.clear();
    } catch (e) {
      debugPrint("Error sending message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send message."),
        ),
      );
    }
  }
}
