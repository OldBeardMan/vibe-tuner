import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: tutaj dodasz autentykację/ backend
            Provider.of<AuthProvider>(context, listen: false).login();
            context.go('/home');
          },
          child: const Text('Zaloguj się'),
        ),
      ),
    );
  }
}
