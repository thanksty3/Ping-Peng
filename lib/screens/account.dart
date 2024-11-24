import 'package:flutter/material.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/screens/edit_profile.dart';
import 'package:ping_peng/utils.dart';

class Account extends StatefulWidget {
  final String? userId; // User ID of the profile to display (optional)

  const Account({super.key, this.userId});

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
  bool _isCurrentUser = false;
  String _friendStatus = 'add';

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
      final currentUserId = (await _databaseService.getCurrentUser())?.uid;
      final userId = widget.userId ?? currentUserId;

      if (userId == null) {
        throw Exception("No user ID provided or logged in.");
      }

      _isCurrentUser = currentUserId == userId;

      // Fetch the user's data
      final userData = await _databaseService.getUserDataForUserId(userId);
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

      // Determine friend status
      if (widget.userId != null) {
        final friendStatus = await _databaseService.getFriendStatus(
          currentUserId!,
          userId,
        );
        setState(() {
          _friendStatus = friendStatus;
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

  Future<void> _handleFriendButtonPress() async {
    try {
      final currentUserId = (await _databaseService.getCurrentUser())?.uid;
      final profileUserId = widget.userId;

      if (currentUserId == null || profileUserId == null) {
        throw Exception("Invalid user IDs for friendship action.");
      }

      switch (_friendStatus) {
        case 'add':
          await _databaseService.addFriend(currentUserId, profileUserId);
          setState(() {
            _friendStatus = 'pending';
          });
          break;
        case 'pending':
          await _databaseService.denyFriendRequest(
              currentUserId, profileUserId);
          setState(() {
            _friendStatus = 'add';
          });
          break;
        case 'add_back':
          await _databaseService.acceptFriendRequest(
              currentUserId, profileUserId);
          setState(() {
            _friendStatus = 'friends';
          });
          break;
        case 'friends':
          await _databaseService.removeFriend(currentUserId, profileUserId);
          setState(() {
            _friendStatus = 'add';
          });
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AccountNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 5),

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
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '@$_username',
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Edit Profile or Add/Remove Friend Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isCurrentUser
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfilePage()),
                                ).then((_) => _loadUserData());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Edit Profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _handleFriendButtonPress,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _friendStatus == 'friends'
                                    ? Colors.red
                                    : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _friendStatus == 'pending'
                                    ? 'Pending Request'
                                    : _friendStatus == 'add_back'
                                        ? 'Add Back'
                                        : _friendStatus == 'friends'
                                            ? 'Remove Friendly Peng'
                                            : 'Add Friendly Peng',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Peng Quote and Interests
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  _pengQuote.isNotEmpty
                                      ? '"$_pengQuote"'
                                      : 'No Peng Quote yet.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
