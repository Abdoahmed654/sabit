import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 64,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(
      Icons.mosque_outlined,
      size: size,
      color: color ?? theme.colorScheme.primary,
    );
  }
}
