import 'package:flutter/material.dart';
import 'package:sapit/features/Auth/presentation/widgets/text_field_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,),
      body: Column(
        children: [
          TextFieldLoginScreen(labelText: 'username', hintText: 'username'),
          TextFieldLoginScreen(labelText: 'gender', hintText: 'gender'),
          TextFieldLoginScreen(labelText: 'email', hintText: 'email'),
          TextFieldLoginScreen(labelText: 'password', hintText: 'password'),
        ],
      ),
    );
  }
}