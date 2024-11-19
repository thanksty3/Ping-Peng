// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/screens/account.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  List<String> interests = [
    'Anime',
    'Comedy',
    'Cooking',
    'Dancing',
    'Drawing',
    'Fashion',
    'Fitness',
    'Food',
    'Gaming',
    'Gardening',
    'Hiking',
    'Movies',
    'Music',
    'Pets',
    'Photography',
    'Reading',
    'Science',
    'Sports',
    'Tech',
    'Traveling',
    'TV Shows',
    'Writing',
    'Yoga'
  ];

  List<String> myInterests = [];
  final TextEditingController _quoteController = TextEditingController();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (userId != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          myInterests = List<String>.from(userData['myInterests'] ?? []);
          _quoteController.text = userData['pengQuote'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'myInterests': myInterests,
        'pengQuote': _quoteController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Information saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Text(
              'My Interests:',
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Jua'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: myInterests.map((interest) {
                return ChoiceChip(
                  label: Text(interest,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 15)),
                  selected: true,
                  selectedColor: Colors.orange,
                  onSelected: (selected) {
                    setState(() {
                      myInterests.remove(interest);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Interests:',
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Jua'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: interests
                  .where((interest) => !myInterests.contains(interest))
                  .map((interest) {
                return ChoiceChip(
                  label: Text(interest,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                  selected: false,
                  backgroundColor: Colors.black87,
                  onSelected: (selected) {
                    setState(() {
                      myInterests.add(interest);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 70),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Account()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: 'Jua'),
                  ),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                        color: Colors.white, fontSize: 20, fontFamily: 'Jua'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
