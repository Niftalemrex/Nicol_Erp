import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onLogin;

  const LoginForm({
    super.key,
    required this.email,
    required this.password,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
        TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onLogin, child: const Text("Login")),
      ],
    );
  }
}