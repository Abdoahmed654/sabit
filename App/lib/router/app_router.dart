import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/core/widgets/main_scaffold.dart';
import 'package:sapit/features/auth/presentation/pages/login_screen.dart';
import 'package:sapit/features/auth/presentation/pages/register_screen.dart';
import 'package:sapit/features/challenges/presentation/pages/challenges_screen.dart';
import 'package:sapit/features/chat/presentation/pages/chat_groups_screen.dart';
import 'package:sapit/features/daily/presentation/pages/good_deeds_screen.dart';
import 'package:sapit/features/friends/presentation/pages/add_friend_screen.dart';
import 'package:sapit/features/friends/presentation/pages/friend_requests_screen.dart';
import 'package:sapit/features/friends/presentation/pages/friends_list_screen.dart';
import 'package:sapit/features/friends/presentation/pages/pending_requests_screen.dart';
import 'package:sapit/features/home/presentation/pages/home_screen.dart';
import 'package:sapit/features/leaderboard/presentation/pages/leaderboard_screen.dart';
import 'package:sapit/features/more/presentation/pages/more_screen.dart';

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
        path: '/login',
        name: 'login-page',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => MainScaffold(
          currentPath: state.uri.toString(),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/good-deeds',
        name: 'good-deeds',
        builder: (context, state) => MainScaffold(
          currentPath: state.uri.toString(),
          child: const GoodDeedsScreen(),
        ),
      ),
      GoRoute(
        path: '/challenges',
        name: 'challenges',
        builder: (context, state) => MainScaffold(
          currentPath: state.uri.toString(),
          child: const ChallengesScreen(),
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => MainScaffold(
          currentPath: state.uri.toString(),
          child: const ChatGroupsScreen(),
        ),
      ),
      GoRoute(
        path: '/more',
        name: 'more',
        builder: (context, state) => MainScaffold(
          currentPath: state.uri.toString(),
          child: const MoreScreen(),
        ),
      ),
      GoRoute(
        path: '/friends',
        name: 'friends',
        builder: (context, state) => const FriendsListScreen(),
      ),
      GoRoute(
        path: '/friends/add',
        name: 'friends-add',
        builder: (context, state) => const AddFriendScreen(),
      ),
      GoRoute(
        path: '/friends/requests',
        name: 'friends-requests',
        builder: (context, state) => const PendingRequestsScreen(),
      ),
      GoRoute(
        path: '/friend-requests',
        name: 'friend-requests',
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
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
