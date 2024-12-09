import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/shows.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  int _currentUserIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMoreUsers = _currentUserIndex < _users.length;

    return Scaffold(
      appBar: const HomeNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : hasMoreUsers
              ? Account(
                  key: ValueKey(
                      _users[_currentUserIndex]['userId']), // Forces rebuild
                  userId: _users[_currentUserIndex]['userId'],
                  isHome: true,
                )
              : const Center(
                  child: Text(
                    'No more users!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
      bottomNavigationBar: const HomeNavBottomNavigationBar(),
    );
  }

  void nextUser() {
    setState(() {
      if (_currentUserIndex < _users.length - 1) {
        _currentUserIndex++;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No New Pengs to Show",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.white,
          ),
        );
      }
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No user logged in.");

      final users = await _databaseService.getAllUsersExcept(currentUser.uid);
      users.shuffle();

      setState(() {
        _users = users;
        debugPrint(
            "Loaded users: ${_users.map((user) => user['userId']).toList()}");
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load users: $e",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class HomeNavBottomNavigationBar extends StatelessWidget {
  const HomeNavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeState>();

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Shows()),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              homeState?.nextUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
