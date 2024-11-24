import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/shows.dart';
import 'package:ping_peng/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _sendFriendRequest(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No user is logged in.");

      // Here, you can implement sending a friendship request to Firestore
      await _databaseService.addFriend(currentUser.uid, userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friendship request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send friend request: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : _users.isEmpty
              ? Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // User's Profile Picture
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: _users[_currentIndex]
                                        ['profilePictureUrl'] !=
                                    null
                                ? NetworkImage(
                                    _users[_currentIndex]['profilePictureUrl'])
                                : AssetImage('assets/images/default_avatar.png')
                                    as ImageProvider,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // User's Name and Username
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${_users[_currentIndex]['firstName']} ${_users[_currentIndex]['lastName']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Jua',
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '@${_users[_currentIndex]['username']}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Buttons for Adding Friend or Showing Next User
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _sendFriendRequest(
                                _users[_currentIndex]['userId']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Send Friendship P!ng',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // User's Peng Quote and Interests
                      Column(
                        children: [
                          // Peng Quote
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Peng Quote',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jua',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      _users[_currentIndex]['pengQuote'] ??
                                          'No quote yet.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Interests
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Interests',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Jua',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: 300,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: (_users[_currentIndex]
                                                  ['myInterests'] as List)
                                              .isNotEmpty
                                          ? (_users[_currentIndex]
                                                      ['myInterests']
                                                  as List<String>)
                                              .map((interest) => Chip(
                                                    backgroundColor:
                                                        Colors.orange,
                                                    label: Text(
                                                      interest,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ))
                                              .toList()
                                          : [
                                              const Text(
                                                'No interests yet.',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
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
