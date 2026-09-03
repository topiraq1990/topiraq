import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onLogin});

  final ValueChanged<String> onLogin;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: controller, textDirection: TextDirection.rtl),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => onLogin(controller.text),
              child: const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }
}