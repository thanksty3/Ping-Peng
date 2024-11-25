import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chatroom extends StatefulWidget {
  const Chatroom({super.key});

  @override
  _ChatroomState createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  String? _chatRoomId;
  late bool myMessage = false;

  @override
  void initState() {
    super.initState();
  }

  String username = '@poptartlover';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              username,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          //other user's messages
          Row(
            children: [
              Column(
                children: [
                  _defaultBox('messages', 0),
                ],
              ),
            ],
          ),
          //message
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  _defaultBox('my message', 1),
                ],
              ),
            ],
          ),

          //send message
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SingleChildScrollView(child: Column()),
                  ],
                ),
                _messageInput(),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _defaultBox(var boxName, int colorFlag) {
    Color chipColor;
    switch (colorFlag) {
      case 1:
        chipColor = Colors.cyanAccent;
      default:
        chipColor = Colors.white;
    }
    Chip box = Chip(
      backgroundColor: chipColor,
      label: Text(
        boxName,
        style: TextStyle(color: Colors.black, fontSize: 17),
      ),
    );

    return box;
  }

  Widget _messageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      height: 75,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type a message...",
                    hintStyle: TextStyle(color: Colors.black, fontSize: 20),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.send_rounded, color: Colors.orange, size: 35),
            onPressed: () => _sendMessage(_messageController.text),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _chatRoomId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'text': message.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chatrooms')
        .doc(_chatRoomId)
        .collection('messages')
        .add(messageData);

    _messageController.clear();
  }
}
