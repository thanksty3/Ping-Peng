// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/forgot_password.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/login.dart';
import 'package:ping_peng/screens/shows.dart';
import 'package:ping_peng/utils/utils.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SettingsNavAppBar(),
      backgroundColor: Colors.black87,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Chats Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Chats()));
                    },
                    style: buttonStyle(false),
                    child: const Text(
                      'Chats',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                divider(),

                // Home Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Home()));
                    },
                    style: buttonStyle(false),
                    child: const Text(
                      'Home',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                divider(),

                // Password Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()),
                      );
                    },
                    style: buttonStyle(false),
                    child: const Text(
                      'Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                divider(),

                // Profile Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Account()),
                      );
                    },
                    style: buttonStyle(false),
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                divider(),

                // Profile Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Shows()),
                      );
                    },
                    style: buttonStyle(false),
                    child: const Text(
                      'Shows',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                divider(),

                // Logout Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () => logOut(context),
                    style: buttonStyle(false),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 45),
                    ),
                  ),
                ),
                divider(),

                // Delete Account Button
                SizedBox(
                  width: 500,
                  child: ElevatedButton(
                    onPressed: () => deleteAccount(context),
                    style: buttonStyle(false),
                    child: const Text(
                      'Delete',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 45,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text(
            'Are you sure you want to delete your account?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text('Agree', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );

      if (confirmed) {
        bool doubleConfirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Are you sure you sure?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.orange)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Agree', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        );

        if (doubleConfirmed) {
          try {
            await user.delete();
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${e.toString()}',
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
      }
    }
  }
}
