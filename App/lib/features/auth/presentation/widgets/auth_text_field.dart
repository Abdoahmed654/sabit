import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const AuthTextField({
    super.key,
    required this.hint,
    this.obscure = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onBackground), // ✅ Dynamic text color
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onBackground.withOpacity(0.6), // ✅ Matches theme text
        ),
        filled: true,
        fillColor: theme.colorScheme.surface, // ✅ Themed fill
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary, // ✅ Yellow when focused
            width: 1.5,
          ),
        ),
      ),
      cursorColor: theme.colorScheme.primary, // ✅ Matches accent color
    );
  }
}
