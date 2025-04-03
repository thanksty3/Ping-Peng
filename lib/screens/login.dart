import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_peng/screens/become_peng.dart';
import 'package:ping_peng/screens/forgot_password.dart';
import 'package:ping_peng/screens/home.dart';
import 'package:ping_peng/screens/edit_profile.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/utils.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Container(
                  height: 350,
                  width: 350,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/P!ngPeng.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                divider(),

                // Email Input
                TextField(
                  cursorColor: orange,
                  style: TextStyle(color: white),
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: white),
                    prefixIcon: const Icon(Icons.email, color: orange),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                divider(),

                // Password Input
                TextField(
                  style: TextStyle(color: white),
                  cursorColor: orange,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: white),
                    prefixIcon: const Icon(Icons.lock, color: orange),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                divider(),

                // Forgot Password and Create Account Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const BecomePeng(),
                                fullscreenDialog: true),
                          );
                        },
                        child: const Text(
                          'Become a Peng!',
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPassword(),
                                fullscreenDialog: true),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                divider(),

                // Login Button
                ElevatedButton(
                  onPressed: signIn,
                  style: buttonStyle(true),
                  child: const Text(
                    'Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final isNewUser =
            await _databaseService.checkIfNewUser(currentUser.uid);

        if (!mounted) return;

        if (isNewUser) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
                fullscreenDialog: true),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const Home(), fullscreenDialog: true),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid Username or Password',
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: black,
        ),
      );
    }
  }
}
