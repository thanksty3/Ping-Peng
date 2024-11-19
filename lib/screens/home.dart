import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/notifications.dart';
import 'package:ping_peng/screens/search.dart';
import 'package:ping_peng/screens/settings.dart';
import 'package:ping_peng/screens/shows.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: NavAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Home Screen Content Goes Here',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Notifications()));
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SearchFriends()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.push(context,
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
            icon: const Icon(Icons.not_interested, color: Colors.red, size: 50),
            onPressed: () {
              //handle switching to next peng
            },
          ),
          IconButton(
            iconSize: 200,
            icon: Image.asset(
              'assets/icons/like-ping.png',
            ),
            onPressed: () {
              //handle adding friend and switching to the next peng
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
