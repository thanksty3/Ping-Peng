import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/edit_info.dart';
import 'package:ping_peng/screens/notifications.dart';
import 'package:ping_peng/screens/settings.dart' as settings;
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/shows.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  static final _quoteController = TextEditingController();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<DocumentSnapshot> getUserData() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String firstName = userData['First Name'] ?? 'First Name';
            String lastName = userData['Last Name'] ?? 'Last Name';
            String username = userData['username'] ?? 'Username';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      height: 200,
                      width: 200,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/P!ngPeng.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$firstName\n$lastName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jua',
                          ),
                        ),
                        Text(
                          '@$username',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Interests Section
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Interests',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: const Text('Sports'),
                                    selected: false,
                                    onSelected: (bool selected) {
                                      // Toggle selection logic here
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Music'),
                                    selected: false,
                                    onSelected: (bool selected) {
                                      // Toggle selection logic here
                                    },
                                  ),
                                  ChoiceChip(
                                    label: const Text('Movies'),
                                    selected: false,
                                    onSelected: (bool selected) {
                                      // Toggle selection logic here
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              TextField(
                                controller: _quoteController,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Let the Pengs know...\nType your quote...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: Colors.orange),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditInfo(),
                          ),
                        );
                      },
                      child: const Text(
                        'Customize',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Jua',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const NavBottomNavigationBar(),
    );
  }
}

class NavAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NavAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.notifications, color: Colors.orange, size: 30),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Notifications()),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.orange, size: 30),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const settings.Settings()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavBottomNavigationBar extends StatelessWidget {
  const NavBottomNavigationBar({super.key});

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
            icon: const Icon(Icons.tv, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Shows()));
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/orange-foot.png', height: 80),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Home()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 30),
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
