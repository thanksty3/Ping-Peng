import 'package:flutter/material.dart';
import 'package:ping_peng/utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NotificationsAppBar(),
      backgroundColor: Colors.black,
    );
  }
}
