import 'package:flutter/material.dart';

class Chatroom extends StatelessWidget {
  const Chatroom({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: const Center(
        child: Text('Chatting with user ID: '),
      ),
    );
  }
}
