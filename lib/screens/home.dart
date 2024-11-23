import 'package:flutter/material.dart';
import 'package:ping_peng/utils.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HomeNavAppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Home Screen Content Goes Here',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
      ),
      bottomNavigationBar: HomeNavBottomNavigationBar(),
    );
  }
}
