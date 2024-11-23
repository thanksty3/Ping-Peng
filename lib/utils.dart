// ignore: unused_import
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/notifications.dart';
import 'package:ping_peng/screens/search.dart';
import 'package:ping_peng/screens/settings.dart';
import 'package:ping_peng/screens/shows.dart';

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
  log('No images selected');
}

class HomeNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeNavAppBar({super.key});

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
                MaterialPageRoute(builder: (context) => SearchScreen()));
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

class ShowsNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShowsNavAppBar({super.key});

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
                MaterialPageRoute(builder: (context) => SearchScreen()));
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

class ShowsNavBottomNavigationBar extends StatelessWidget {
  const ShowsNavBottomNavigationBar({super.key});

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

class ChatsNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatsNavAppBar({super.key});

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
          'CHATS',
          style:
              TextStyle(fontFamily: 'Jua', color: Colors.orange, fontSize: 40),
        ),
        const SizedBox(width: 35),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
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

class ChatsNavBottomNavigationBar extends StatelessWidget {
  const ChatsNavBottomNavigationBar({super.key});

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
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
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
          const SizedBox(width: 50),
        ],
      ),
    );
  }
}

class SearchNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchNavAppBar({super.key});

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
      title: Text(
        'Search',
        style: TextStyle(color: Colors.orange, fontSize: 40, fontFamily: 'Jua'),
      ),
      actions: <Widget>[
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

class SearchNavBottomNavigationBar extends StatelessWidget {
  const SearchNavBottomNavigationBar({super.key});

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
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(context,
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

class AccountNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountNavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.orange, size: 30),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Notifications()),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Settings()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AccountNavBottomNavigationBar extends StatelessWidget {
  const AccountNavBottomNavigationBar({super.key});

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
