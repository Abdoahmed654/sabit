import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/features/auth/presentation/pages/login_screen.dart';
import 'package:sapit/features/auth/presentation/pages/register_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Create the GoRouter instance
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );

  // === Navigation helpers ===
  static void go(String routeName, {Map<String, String>? params}) {
    router.goNamed(routeName, pathParameters: params ?? {});
  }

  static void push(String routeName, {Map<String, String>? params}) {
    router.pushNamed(routeName, pathParameters: params ?? {});
  }

  static void replace(String routeName, {Map<String, String>? params}) {
    router.replaceNamed(routeName, pathParameters: params ?? {});
  }

  static void pop() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState?.pop();
    }
  }
}
