import 'package:flutter/material.dart';
import 'package:sapit/features/Auth/presentation/pages/login_screen.dart';
import 'router/app-router.dart';

void main() {
  runApp(const sabitApp());
}

class sabitApp extends StatelessWidget {
  const sabitApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // routerConfig: AppRouter().router,
      home: LoginPage(),
    );
  }
}