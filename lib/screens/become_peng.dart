// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_peng/utils/database_services.dart' as database;
import 'package:ping_peng/screens/login.dart';
import 'package:ping_peng/utils/utils.dart';

class BecomePeng extends StatefulWidget {
  const BecomePeng({super.key});

  @override
  BecomePengState createState() => BecomePengState();
}

class BecomePengState extends State<BecomePeng> {
  final _dbService = database.DatabaseService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPasswordController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Welcome Friend!",
                    style: TextStyle(
                      fontSize: 45,
                      fontFamily: 'Jua',
                    ),
                  ),
                  divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: buttonStyle(false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: signUp,
                        style: buttonStyle(false),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  divider(),

                  // First Name
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  divider(),

                  // Last Name
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  divider(),

                  // Email
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  divider(),

                  // Username
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  divider(),

                  // Password
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  divider(),

                  // Verify Password
                  TextFormField(
                    cursorColor: Colors.orange,
                    controller: _verifyPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Verify Password',
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: enabledBorder,
                      focusedBorder: focusedBorder,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please re-enter your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Add user data to Firestore using DatabaseService
      await _dbService.createUser(
        userCredential.user?.uid ?? "",
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _usernameController.text,
      );

      // Navigate to Login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              'Error: $errorMessage',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.black),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.black),
      );
    }
  }

  final OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(12),
  );

  final OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.orange),
    borderRadius: BorderRadius.circular(12),
  );
}
