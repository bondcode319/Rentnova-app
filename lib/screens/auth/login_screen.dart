import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentnova/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthProvider>().login('test@test.com', 'password');
          },
          child: const Text('Sign In'),
        ),
      ),
    );
  }
}
