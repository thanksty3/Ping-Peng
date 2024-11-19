// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/settings.dart';
import 'package:ping_peng/screens/shows.dart';

class SearchFriends extends StatelessWidget {
  const SearchFriends({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const NavAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search friends',
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ] // Friends list],
            ),
      ),
      bottomNavigationBar: const NavBottomNavigationBar(),
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
        icon: const Icon(Icons.search, color: Colors.orange, size: 30),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SearchFriends()));
        },
      ),
      actions: <Widget>[
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
      notchMargin: 4,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Shows()));
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 30),
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
