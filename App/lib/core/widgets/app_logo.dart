import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary, // ✅ Uses theme color
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.star_rounded, // placeholder for Islamic/star symbol
            color: theme.colorScheme.onPrimary, // ✅ Contrasting color
            size: size * 0.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SABIT',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary, // ✅ Uses theme color
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
