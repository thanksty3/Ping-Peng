import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/screens/edit_profile.dart';
import 'package:ping_peng/utils.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final DatabaseService _databaseService = DatabaseService();

  String _profilePictureUrl = 'assets/images/P!ngPeng.png';
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _pengQuote = '';
  List<String> _interests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _databaseService.getUserData();
      if (userData != null) {
        setState(() {
          _profilePictureUrl = userData['profilePictureUrl'] ?? '';
          _firstName = userData['firstName'] ?? '';
          _lastName = userData['lastName'] ?? '';
          _username = userData['username'] ?? '';
          _pengQuote = userData['pengQuote'] ?? '';
          _interests = List<String>.from(userData['myInterests'] ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountNavAppBar(),
      backgroundColor: Colors.black87,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Profile Picture
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage: _profilePictureUrl.isNotEmpty
                            ? NetworkImage(_profilePictureUrl)
                            : AssetImage('assets/images/P!ngPeng.png')
                                as ImageProvider,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Name and Username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$_firstName $_lastName',
                            style: TextStyle(
                              fontFamily: 'Jua',
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '@$_username',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditProfilePage()),
                          ).then((_) => _loadUserData());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Peng Quote and Interests
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Peng Quote
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Peng Quote',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                _pengQuote.isNotEmpty
                                    ? '"$_pengQuote"'
                                    : 'No Peng Quote yet.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Interests
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Interests',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.orange),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: _interests.isNotEmpty
                                    ? _interests
                                        .map(
                                          (interest) => Chip(
                                            backgroundColor: Colors.orange,
                                            label: Text(
                                              interest,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Jua',
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList()
                                    : [
                                        const Text(
                                          'No interests yet.',
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const AccountNavBottomNavigationBar(),
    );
  }
}
