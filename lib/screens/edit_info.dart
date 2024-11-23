// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ping_peng/screens/account.dart';

class EditInfo extends StatefulWidget {
  const EditInfo({super.key});

  @override
  _EditInfoState createState() => _EditInfoState();
}

class _EditInfoState extends State<EditInfo> {
  final TextEditingController _quoteController = TextEditingController();
  String? _profilePictureUrl;
  List<String> interests = [
    'Anime',
    'Art',
    'Beau',
    'Comedy',
    'Cooking',
    'Dancing',
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
  ];
  List<String> myInterests = [];

  void showEditPhotoMenu() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.orange,
                ),
                title: const Text('Choose from Photo Library'),
                onTap: () async {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.restore, color: Colors.orange),
                title: const Text('Reset Profile Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {});
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundImage:
                          const AssetImage('assets/images/P!ngPeng.png'),
                    ),
                    Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                            onPressed: showEditPhotoMenu,
                            icon: const Icon(Icons.add_a_photo,
                                color: Colors.orange)))
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                ElevatedButton(
                  onPressed: () {},
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
            const SizedBox(height: 20),
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
                  backgroundColor: Colors.orange,
                  label: Text(
                    interest,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  selected: false,
                  onSelected: (_) {
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
                  label: Text(
                    interest,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  selected: false,
                  backgroundColor: Colors.black87,
                  onSelected: (_) {
                    setState(() {
                      myInterests.add(interest);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Peng Quote:',
              style: TextStyle(
                  fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'Jua'),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLength: 90,
              controller: _quoteController,
              style: const TextStyle(
                  color: Colors.black87, fontSize: 18, fontFamily: 'Poppins'),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What do you have to say?...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black87),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
