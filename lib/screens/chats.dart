import 'package:flutter/material.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/shows.dart';

class Chats extends Home {
  const Chats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavAppBar(),
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: NavBottomNavigationBar(),
    );
  }
}

class NavBottomNavigationBar extends StatelessWidget {
  const NavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Shows()));
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Shows()));
            },
          ),
        ],
      ),
    );
  }
}
