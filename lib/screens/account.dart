import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/screens/chatroom.dart';
import 'package:ping_peng/screens/edit_profile.dart';
import 'package:ping_peng/utils/utils.dart';

class Account extends StatefulWidget {
  final String? userId;
  final bool isHome;
  const Account({super.key, this.userId, this.isHome = false});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.isHome ? const AccountNavAppBar() : null,
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : accountPage(),
      bottomNavigationBar:
          !widget.isHome ? const AccountNavBottomNavigationBar() : null,
    );
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Failed to load user data: $e',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
      ));
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
        SnackBar(
          content: Text(
            'Action failed: $e',
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
  }

  Widget accountPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Profile Picture
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 120,
                backgroundImage: _profilePictureUrl.isNotEmpty
                    ? NetworkImage(_profilePictureUrl)
                    : AssetImage('assets/images/P!ngPeng.png') as ImageProvider,
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
                  mainText('$_firstName $_lastName'),
                  nameOfUser(),
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
                      style: buttonStyle(false),
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
          if (_friendStatus == 'friends') // Conditionally show the button
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    if (currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Error: User is not logged in.",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatroom(
                          username: _username,
                          chatRoomId:
                              '${widget.userId}_$currentUserId', // Correct ID
                          friendProfilePictureUrl: _profilePictureUrl,
                          friendUserId: widget.userId!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
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
                      mainText('Peng Quote'),
                      const SizedBox(height: 10),
                      Container(
                        width: 300,
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
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              divider(),

              // Interests
              interestsSection(),
              divider(),

              // Shows Section
              mainText('Shows'),
              divider(),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _databaseService.getUserPosts(widget.userId ??
                    (FirebaseAuth.instance.currentUser?.uid ?? '')),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No shows available.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  final posts = snapshot.data!;
                  return Column(
                    children: posts.map((post) {
                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: post['type'] == 'photo'
                                ? Image.network(
                                    post['mediaUrl'],
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Icon(Icons.videocam,
                                        color: Colors.orange, size: 100),
                                  ),
                          ),
                          divider(),
                          //delete user's post if on account page
                          if (_isCurrentUser)
                            ElevatedButton(
                              onPressed: () async {
                                await _databaseService
                                    .deletePost(post['postId']);
                                setState(() {});
                              },
                              style: buttonStyle(true),
                              child: const Text(
                                'Delete Post',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          divider()
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Text nameOfUser() {
    return Text(
      '@$_username',
      style: TextStyle(
        fontSize: 20,
        fontFamily: 'Jua',
        color: Colors.orange,
      ),
    );
  }

  Text mainText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jua',
        color: Colors.white,
      ),
    );
  }

  Row interestsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mainText('Interests'),
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
                                  fontSize: 18),
                            ),
                          ),
                        )
                        .toList()
                    : [
                        const Text(
                          'No interests yet.',
                          style: TextStyle(
                              color: Colors.orange,
                              fontFamily: 'Jua',
                              fontSize: 18),
                        )
                      ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
