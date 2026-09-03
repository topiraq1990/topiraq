import 'package:flutter/material.dart';

class CoinBalance extends StatelessWidget {
  const CoinBalance({super.key, required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on_rounded, color: Color(0xFFD9A65F)),
        const SizedBox(width: 6),
        Text('$amount', style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}