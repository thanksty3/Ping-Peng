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

  String _profilePictureUrl = 'assets/images/Black_Peng.png';
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
      backgroundColor: black,
      body: _isLoading
          ? Text(
              'Loading Profile...',
              style: TextStyle(color: white, fontSize: 18),
            )
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
            color: black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: white,
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
              color: black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: black,
                radius: 120,
                backgroundImage: _profilePictureUrl.isNotEmpty
                    ? NetworkImage(_profilePictureUrl)
                    : const AssetImage('assets/images/Black_Peng.png')
                        as ImageProvider,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  mainText('@$_username'),
                  nameOfUser(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isCurrentUser
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        ).then((updatedProfilePictureUrl) {
                          if (updatedProfilePictureUrl != null) {
                            setState(() {
                              _profilePictureUrl = updatedProfilePictureUrl;
                            });
                          } else {
                            _loadUserData();
                          }
                        });
                      },
                      style: buttonStyle(false),
                      child: const Text(
                        'Edit Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: black,
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
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ],
          ),
          if (_friendStatus == 'friends')
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
                              color: black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          backgroundColor: white,
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chatroom(
                          username: _username,
                          chatRoomId: '${widget.userId}_$currentUserId',
                          friendProfilePictureUrl: _profilePictureUrl,
                          friendUserId: widget.userId!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      color: black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 5),
          // Only show the report button if this is NOT the current user
          if (!_isCurrentUser)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                onPressed: _showReportMenu, // <--- Show the bottom sheet
                icon: const Icon(
                  Icons.report_problem,
                  color: orange,
                  size: 45,
                ),
              )
            ]),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                          border: Border.all(color: orange),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _pengQuote.isNotEmpty
                              ? '"$_pengQuote"'
                              : 'No Peng Quote yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              divider(),
              interestsSection(),
              divider(),
              mainText('Shows'),
              divider(),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _databaseService.getUserPosts(widget.userId ??
                    (FirebaseAuth.instance.currentUser?.uid ?? '')),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: orange),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No shows available.',
                        style: TextStyle(color: white),
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
                                        color: orange, size: 100),
                                  ),
                          ),
                          divider(),
                          if (_isCurrentUser)
                            ElevatedButton(
                              onPressed: () async {
                                await _databaseService
                                    .deletePost(post['postId']);
                                setState(() {});
                              },
                              style: deletePost(),
                              child: const Text(
                                'Delete Post',
                                style: TextStyle(
                                  color: white,
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
      '$_firstName $_lastName',
      style: const TextStyle(
        fontSize: 25,
        fontFamily: 'Jua',
        color: orange,
      ),
    );
  }

  Text mainText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jua',
        color: white,
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
                border: Border.all(color: orange),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _interests.isNotEmpty
                    ? _interests
                        .map(
                          (interest) => Chip(
                            backgroundColor: orange,
                            label: Text(
                              interest,
                              style: const TextStyle(
                                  color: white,
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
                              color: orange, fontFamily: 'Jua', fontSize: 18),
                        )
                      ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Show bottom sheet with Block/Unblock and Report ---
  void _showReportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: black,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text(
                'Block/Unblock User',
                style: TextStyle(color: white),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleBlockUnblock();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: orange),
              title: const Text(
                'Report User',
                style: TextStyle(color: white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showReportPrompt();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleBlockUnblock() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Block/Unblock action triggered',
          style: TextStyle(
            color: black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: white,
      ),
    );

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || widget.userId == null) {
      return;
    }
    try {
      final userData =
          await _databaseService.getUserDataForUserId(currentUserId);
      if (userData == null) return;

      final blockedUsers = List<String>.from(userData['blockedUsers'] ?? []);
      if (blockedUsers.contains(widget.userId)) {
        await _databaseService.unblockUser(currentUserId, widget.userId!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You have unblocked $_username',
              style: const TextStyle(
                color: black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: white,
          ),
        );
      } else {
        await _databaseService.blockUser(currentUserId, widget.userId!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You have blocked $_username',
              style: const TextStyle(
                color: black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: white,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Block/Unblock failed: $e',
            style: const TextStyle(
              color: black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: white,
        ),
      );
    }
  }

  void _showReportPrompt() {
    final TextEditingController reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: black,
          title: const Text(
            'Report User',
            style: TextStyle(color: white),
          ),
          content: TextField(
            cursorColor: orange,
            controller: reportController,
            maxLines: 5,
            style: const TextStyle(color: white),
            decoration: const InputDecoration(
              hintText: 'Describe the issue here...',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: white),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: orange),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: orange),
              ),
            ),
            TextButton(
              onPressed: () async {
                final reportText = reportController.text.trim();
                if (reportText.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Report submitted: $reportText',
                        style: const TextStyle(
                          color: black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      backgroundColor: white,
                    ),
                  );

                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  if (currentUserId != null && widget.userId != null) {
                    final currentUserData = await _databaseService
                        .getUserDataForUserId(currentUserId);
                    final reportedUserData = await _databaseService
                        .getUserDataForUserId(widget.userId!);

                    if (currentUserData != null && reportedUserData != null) {
                      await _databaseService.reportUser(
                        reporterId: currentUserId,
                        reporterUsername:
                            currentUserData['username'] ?? 'unknown',
                        reportedId: widget.userId!,
                        reportedUsername:
                            reportedUserData['username'] ?? 'unknown',
                        reportedEmail: reportedUserData['email'] ?? 'N/A',
                        reason: reportText,
                      );
                    }
                  }
                }
                Navigator.pop(context);
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: orange),
              ),
            ),
          ],
        );
      },
    );
  }
}
