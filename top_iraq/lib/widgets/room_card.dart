import 'package:flutter/material.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({
    super.key,
    required this.name,
    required this.members,
    this.onTap,
  });

  final String name;
  final int members;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.mic_rounded)),
        title: Text(name),
        subtitle: Text('$members موجودين'),
        onTap: onTap,
      ),
    );
  }
}