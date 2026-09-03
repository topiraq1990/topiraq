import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الملف الشخصي')),
        body: Center(child: Text(username)),
      );
}
