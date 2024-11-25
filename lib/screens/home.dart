import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/shows.dart';
import 'package:ping_peng/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavAppBar(),
      backgroundColor: Colors.black,
      bottomNavigationBar: const HomeNavBottomNavigationBar(),
    );
  }
}

class HomeNavBottomNavigationBar extends StatelessWidget {
  const HomeNavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 2,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Shows()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Chats()));
            },
          ),
        ],
      ),
    );
  }
}
