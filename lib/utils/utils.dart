import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/notifications.dart';
import 'package:ping_peng/screens/search.dart';
import 'package:ping_peng/screens/settings.dart';
import 'package:ping_peng/screens/shows.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
  log('No images selected');
  return null;
}

const Color orange = Colors.orange;
const Color black = Colors.black;
const Color white = Colors.white;

Text header(String title) {
  return Text(
    title,
    style: TextStyle(fontFamily: 'Jua', color: orange, fontSize: 40),
  );
}

SizedBox divider() {
  return const SizedBox(height: 15);
}

SizedBox spacer() {
  return const SizedBox(width: 30);
}

ButtonStyle deletePost() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

ButtonStyle buttonStyle(bool isLogin) {
  Color buttonColor = isLogin ? orange : Colors.white;

  return ElevatedButton.styleFrom(
    backgroundColor: buttonColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

class NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const NotificationsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: orange),
      backgroundColor: black,
      title: header(' Peng Requests'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HomeNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeNavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: orange, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
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

class ShowsNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShowsNavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: orange, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
      ),
      actions: <Widget>[
        header('Shows'),
        IconButton(
          icon: const Icon(Icons.search, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        IconButton(
            icon: const Icon(Icons.person_2_rounded, color: orange, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Account()));
            }),
        IconButton(
          icon: const Icon(Icons.settings, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
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

class ChatsNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatsNavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: orange, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
      ),
      actions: <Widget>[
        header('Chats'),
        IconButton(
          icon: const Icon(Icons.search, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        IconButton(
            icon: const Icon(Icons.person_2_rounded, color: orange, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Account()));
            }),
        IconButton(
          icon: const Icon(Icons.settings, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
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

class ChatsNavBottomNavigationBar extends StatelessWidget {
  const ChatsNavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      color: black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Shows()),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
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
      backgroundColor: black,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: orange, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
      ),
      title: Text(
        '\t\t\t\t\t\tSearch',
        style: TextStyle(color: orange, fontSize: 40, fontFamily: 'Jua'),
      ),
      actions: <Widget>[
        IconButton(
            icon: const Icon(Icons.person_2_rounded, color: orange, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Account()));
            }),
        IconButton(
          icon: const Icon(Icons.settings, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
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

class SearchNavBottomNavigationBar extends StatelessWidget {
  const SearchNavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 4,
      color: black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Shows()),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Chats()),
              );
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
      iconTheme: IconThemeData(color: orange),
      backgroundColor: black,
      elevation: 1,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, size: 30),
          onPressed: () {
            Navigator.push(
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
      color: black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Shows()),
              );
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Chats()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SettingsNavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsNavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: black,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: orange, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const NotificationsScreen()),
          );
        },
      ),
      actions: <Widget>[
        header('Settings'),
        const SizedBox(width: 65),
        IconButton(
          icon: const Icon(Icons.search, color: orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
