import 'package:flutter/material.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController password;

  final String role;
  final Function(String?) onRoleChanged;

  final Future<void> Function() onSignup;

  const SignupForm({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.onRoleChanged,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: "Name"),
        ),

        TextField(
          controller: email,
          decoration: const InputDecoration(labelText: "Email"),
        ),

        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password"),
        ),

        const SizedBox(height: 10),

        // 🔥 ROLE SELECTOR (UPDATED)
        DropdownButtonFormField<String>(
          value: role,
          decoration: const InputDecoration(
            labelText: "Select Role",
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'designer',
              child: Text('🎨 Designer'),
            ),
            DropdownMenuItem(
              value: 'printer',
              child: Text('🖨 Printer'),
            ),
            DropdownMenuItem(
              value: 'cashier',
              child: Text('💰 Cashier'),
            ),
            DropdownMenuItem(
              value: 'finishing',
              child: Text('✂️ Finishing'),
            ),
            DropdownMenuItem(
              value: 'manager',
              child: Text('📊 Manager'), // 🔥 ADDED
            ),
          ],
          onChanged: onRoleChanged,
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await onSignup();
            },
            child: const Text("Sign Up"),
          ),
        ),
      ],
    );
  }
}