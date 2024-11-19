import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/search.dart';
import 'package:ping_peng/screens/settings.dart';

import 'notifications.dart';

class Shows extends Home {
  const Shows({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: NavBottomNavigationBar(),
    );
  }
}

class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.orange, size: 30),
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const Notifications()));
        },
      ),
      actions: <Widget>[
        const Text(
          'Shows',
          style:
              TextStyle(fontFamily: 'Jua', color: Colors.orange, fontSize: 40),
        ),
        const SizedBox(width: 35),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SearchFriends()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Settings()));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 50),
            onPressed: () {
              null;
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
            icon: const Icon(Icons.chat, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Chats()));
            },
          ),
        ],
      ),
    );
  }
}
