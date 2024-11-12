import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ping_peng/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Login(),
        theme: ThemeData(
          fontFamily: 'Poppins',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(
                fontFamily: 'Jua',
                fontWeight: FontWeight.w400,
                color: Colors.orange),
            bodyMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.orange),
            displayLarge: TextStyle(
                fontFamily: 'Jua',
                fontWeight: FontWeight.w900,
                color: Colors.orange),
            displayMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
                color: Colors.orange),
          ),
        ));
  }
}
