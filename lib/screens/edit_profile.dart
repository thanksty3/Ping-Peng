// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/lists.dart';
import 'package:ping_peng/utils/utils.dart';

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

  String _temporaryProfilePictureUrl = '';
  String _temporaryQuote = '';
  List<String> _temporaryInterests = [];
  bool _isNewUser = false;

  final List<String> interests = Interests().getInterests();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _databaseService.getCurrentUser();
      if (user == null) throw Exception("No user is logged in.");

      final isNewUser = await _databaseService.checkIfNewUser(user.uid);
      final userData = await _databaseService.getUserData();

      setState(() {
        _isNewUser = isNewUser;
        if (userData != null) {
          _profilePictureUrl = userData['profilePictureUrl'] ?? '';
          _pengQuoteController.text = userData['pengQuote'] ?? '';
          _myInterests = List<String>.from(userData['myInterests'] ?? []);
          _temporaryProfilePictureUrl = _profilePictureUrl;
          _temporaryQuote = _pengQuoteController.text;
          _temporaryInterests = List<String>.from(_myInterests);
        }
      });
    } catch (e) {
      _showSnackBar('Failed to load user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _revertChanges();
        return true;
      },
      child: Scaffold(
        backgroundColor: black,
        appBar: AppBar(
          backgroundColor: black,
          iconTheme: const IconThemeData(color: orange),
          leading: IconButton(
            onPressed: () {
              _revertChanges();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: _isLoading ? null : _saveUserData,
              icon: const Icon(Icons.check, size: 25),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: orange))
            : _editProfileScreen(),
      ),
    );
  }

  Future<void> _saveUserData() async {
    setState(() => _isLoading = true);

    try {
      String? updatedProfilePictureUrl = _profilePictureUrl;

      if (_temporaryProfilePictureUrl.isNotEmpty &&
          !_temporaryProfilePictureUrl.startsWith('http')) {
        final imageFile = File(_temporaryProfilePictureUrl);

        await _databaseService.uploadAndSaveProfilePicture(imageFile);

        updatedProfilePictureUrl = await _databaseService.getProfilePictureUrl(
          (await _databaseService.getCurrentUser())!.uid,
        );
      }

      await _databaseService.updateUserData(
        pengQuote: _temporaryQuote.trim(),
        myInterests: _temporaryInterests,
      );

      setState(() {
        _profilePictureUrl = updatedProfilePictureUrl ?? _profilePictureUrl;
        _temporaryProfilePictureUrl = _profilePictureUrl;
        _myInterests = List.from(_temporaryInterests);
        _pengQuoteController.text = _temporaryQuote;
      });

      final user = await _databaseService.getCurrentUser();
      if (user != null && _isNewUser) {
        await _databaseService.setNewUserFlag(user.uid, false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        Navigator.pop(
          context,
          MaterialPageRoute(builder: (context) => const Account()),
        );
      }
    } catch (e) {
      _showSnackBar('Failed to save user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _revertChanges() {
    setState(() {
      _temporaryProfilePictureUrl = _profilePictureUrl;
      _temporaryQuote = _pengQuoteController.text;
      _temporaryInterests = List.from(_myInterests);
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  Future<void> _chooseProfilePicture() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _temporaryProfilePictureUrl = pickedFile.path;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image: $e');
    }
  }

  Widget _editProfileScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 100,
            backgroundColor: black,
            backgroundImage: _temporaryProfilePictureUrl.isNotEmpty
                ? (_temporaryProfilePictureUrl.startsWith('http')
                        ? NetworkImage(_temporaryProfilePictureUrl)
                        : FileImage(File(_temporaryProfilePictureUrl)))
                    as ImageProvider
                : const AssetImage('assets/images/Black_Peng.png'),
          ),
          const SizedBox(height: 20),
          _buildEditButton('Edit Profile Picture', _chooseProfilePicture),
          const SizedBox(height: 20),
          TextField(
            textAlign: TextAlign.center,
            controller: _pengQuoteController,
            cursorColor: orange,
            maxLines: 3,
            maxLength: 125,
            onChanged: (value) {
              _temporaryQuote = value;
            },
            decoration: const InputDecoration(
              label: Text(
                'Peng Quote',
                style: TextStyle(
                  color: orange,
                  fontFamily: 'Jua',
                  fontSize: 30,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: orange),
              ),
            ),
            style: const TextStyle(color: white),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Interests:',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Jua',
                color: orange,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildInterestsChips(),
        ],
      ),
    );
  }

  Widget _buildEditButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: buttonStyle(false),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInterestsChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: interests.map((interest) {
        final isSelected = _temporaryInterests.contains(interest);
        return FilterChip(
          backgroundColor: isSelected ? Colors.orange[100] : Colors.grey[800],
          selectedColor: orange,
          label: Text(
            interest,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isSelected ? white : orange,
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _temporaryInterests.add(interest);
              } else {
                _temporaryInterests.remove(interest);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
