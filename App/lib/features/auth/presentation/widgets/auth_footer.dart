import 'package:flutter/material.dart';
import 'package:sapit/router/app_router.dart';

class AuthFooter extends StatelessWidget {
  final String buttonText;
  final String to;

  const AuthFooter({
    super.key,
    required this.buttonText,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: () => AppRouter.push(to),
        child: Text(
          buttonText,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
