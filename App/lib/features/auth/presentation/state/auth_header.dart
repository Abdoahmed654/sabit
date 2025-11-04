import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {

  final String title;
  const AuthHeader({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Login to continue your journey",
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}
