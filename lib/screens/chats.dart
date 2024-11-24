import 'package:flutter/material.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/utils.dart';

class Chats extends Home {
  const Chats({super.key});

  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: ChatsNavAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: ChatsNavBottomNavigationBar(),
    );
  }
}
