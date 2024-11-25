import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_peng/database_services.dart';
import 'package:ping_peng/lists.dart';
import 'package:ping_peng/utils.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _pengQuoteController = TextEditingController();
  String _profilePictureUrl = '';
  List<String> _myInterests = [];
  bool _isLoading = false;

  final List<String> interests = Interests().getInterests();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.orange),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveUserData,
            icon: const Icon(Icons.check, size: 25),
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : editProfileScreen(),
      bottomNavigationBar: AccountNavBottomNavigationBar(),
    );
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _databaseService.getUserData();
      if (userData != null) {
        setState(() {
          _profilePictureUrl = userData['profilePictureUrl'] ?? '';
          _myInterests = List<String>.from(userData['myInterests'] ?? []);
          _pengQuoteController.text = userData['pengQuote'] ?? '';
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

  // Save user data to Firestore
  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _databaseService.updateUserData(
        pengQuote: _pengQuoteController.text.trim(),
        myInterests: _myInterests,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Handle profile picture selection and upload
  Future<void> _chooseProfilePicture() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.orange),
              title: Text(
                'Choose from Photo Library',
                style: TextStyle(color: Colors.orange),
              ),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _isLoading = true;
                    });

                    final image = File(pickedFile.path);
                    await _databaseService.uploadAndSaveProfilePicture(image);

                    final updatedUrl =
                        await _databaseService.getProfilePictureUrl(
                            (await _databaseService.getCurrentUser())!.uid);
                    if (mounted) {
                      setState(() {
                        _profilePictureUrl = updatedUrl ?? '';
                        _isLoading = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile picture updated!')),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update picture: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget editProfileScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 100,
            backgroundImage: _profilePictureUrl.isNotEmpty
                ? NetworkImage(_profilePictureUrl)
                : AssetImage('assets/images/P!ngPeng.png') as ImageProvider,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _chooseProfilePicture,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Edit Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            textAlign: TextAlign.center,
            controller: _pengQuoteController,
            cursorColor: Colors.orange,
            maxLines: 3,
            maxLength: 125,
            decoration: InputDecoration(
              label: const Text(
                'Peng Quote',
                style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'Jua',
                  fontSize: 30,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Interests:',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Jua',
                color: Colors.orange,
              ),
            ),
          ),
          SizedBox(height: 10),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: interests.map((interest) {
              final isSelected = _myInterests.contains(interest);
              return FilterChip(
                backgroundColor:
                    isSelected ? Colors.orange[100] : Colors.grey[800],
                selectedColor: Colors.orange,
                label: Text(
                  interest,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected ? Colors.white : Colors.orange,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _myInterests.add(interest);
                    } else {
                      _myInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
