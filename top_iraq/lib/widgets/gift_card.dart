import 'package:flutter/material.dart';

class GiftCard extends StatelessWidget {
  const GiftCard({
    super.key,
    required this.name,
    required this.price,
    this.onSend,
  });

  final String name;
  final int price;
  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.card_giftcard_rounded),
        title: Text(name),
        subtitle: Text('$price عملة'),
        trailing: IconButton(
          onPressed: onSend,
          icon: const Icon(Icons.send_rounded),
          tooltip: 'إرسال الهدية',
        ),
      ),
    );
  }
}