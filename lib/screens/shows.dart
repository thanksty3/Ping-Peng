import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/utils/utils.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'dart:io';

class Shows extends StatefulWidget {
  const Shows({super.key});

  @override
  _ShowsState createState() => _ShowsState();
}

class _ShowsState extends State<Shows> {
  final PageController _horizontalPageController = PageController();
  final PageController _verticalPageController = PageController();
  final DatabaseService _databaseService = DatabaseService();

  List<Map<String, dynamic>> _friendsPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFriendsPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ShowsNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: Text(
              'Loading Shows...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ))
          : _friendsPosts.isEmpty
              ? const Center(
                  child: Text(
                    "No shows available!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : PageView.builder(
                  controller: _horizontalPageController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _friendsPosts.length,
                  itemBuilder: (context, friendIndex) {
                    final friendPosts = _friendsPosts[friendIndex]['posts'];
                    return friendPosts.isEmpty
                        ? Center(
                            child: Text(
                              "No posts from this user.",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : PageView.builder(
                            controller: _verticalPageController,
                            scrollDirection: Axis.vertical,
                            itemCount: friendPosts.length,
                            itemBuilder: (context, postIndex) {
                              return _buildPostView(
                                friendPosts[postIndex],
                                _friendsPosts[friendIndex],
                              );
                            },
                          );
                  },
                ),
      bottomNavigationBar: const ShowsNavBottomNavigationBar(),
    );
  }

  Future<void> _fetchFriendsPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No user is logged in.");

      final friendsPosts =
          await _databaseService.getFriendsPosts(currentUser.uid);

      final groupedPosts = <Map<String, dynamic>>[];
      for (var post in friendsPosts) {
        final friendIndex = groupedPosts
            .indexWhere((friend) => friend['userId'] == post['userId']);
        if (friendIndex == -1) {
          groupedPosts.add({
            'userId': post['userId'],
            'firstName': post['firstName'],
            'lastName': post['lastName'],
            'username': post['username'],
            'profilePictureUrl': post['profilePictureUrl'],
            'posts': [post],
          });
        } else {
          groupedPosts[friendIndex]['posts'].add(post);
        }
      }

      setState(() {
        _friendsPosts = groupedPosts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed to load shows: $e",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _showUploadMenu(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.black,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.orange),
                title: const Text("Upload Photo",
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    await _uploadMedia(context, File(photo.path), 'photo');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.orange),
                title: const Text("Take Photo",
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? media =
                      await picker.pickImage(source: ImageSource.camera);
                  if (media != null) {
                    await _uploadMedia(context, File(media.path), 'photo');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadMedia(
      BuildContext context, File file, String type) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No user is logged in.");

      final userId = currentUser.uid;
      final username = (await _databaseService.getUserData())?['username'];

      final ref = await _databaseService.uploadPostToStorage(file, userId);

      await _databaseService.addPost(userId, username, ref, type);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Post uploaded successfully!",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to upload post: $e",
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ));
    }
  }

  Widget _buildPostView(
      Map<String, dynamic> post, Map<String, dynamic> friendData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        Material(
          color: Colors.black, // Ensure the row matches the background
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Account(userId: friendData['userId']),
                    fullscreenDialog: true),
              );
            },
            splashColor: Colors.orange.withOpacity(0.2), // Ripple effect
            highlightColor: Colors.orange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundImage: (friendData['profilePictureUrl'] != null &&
                            friendData['profilePictureUrl'].isNotEmpty)
                        ? NetworkImage(friendData['profilePictureUrl'])
                        : const AssetImage('assets/images/Black_Peng.png')
                            as ImageProvider,
                    backgroundColor: black,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@${friendData['username']}',
                        style: const TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${friendData['firstName']} ${friendData['lastName']}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: post['type'] == 'photo'
              ? Image.network(post['mediaUrl'], fit: BoxFit.cover)
              : Center(
                  child: Icon(Icons.videocam, color: Colors.orange, size: 100),
                ),
        ),
      ],
    );
  }
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
              final state = context.findAncestorStateOfType<_ShowsState>();
              state?._showUploadMenu(context);
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Home(),
                      fullscreenDialog: true));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Chats(),
                      fullscreenDialog: true));
            },
          ),
        ],
      ),
    );
  }
}
