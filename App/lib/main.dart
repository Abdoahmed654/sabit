import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/di/injection_container.dart' as di;
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_bloc.dart';
import 'package:sapit/features/daily/presentation/bloc/good_deeds_bloc.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'package:sapit/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:sapit/core/theme/app_theme.dart';
import 'package:sapit/core/theme/theme_cubit.dart';
import 'package:sapit/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const SabitApp());
}

class SabitApp extends StatelessWidget {
  const SabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
        BlocProvider(create: (_) => di.sl<FriendsBloc>()),
        BlocProvider(create: (_) => di.sl<DailyBloc>()),
        BlocProvider(create: (_) => di.sl<GoodDeedsBloc>()),
        BlocProvider(create: (_) => di.sl<LeaderboardBloc>()),
        BlocProvider(create: (_) => di.sl<ShopBloc>()),
        // Theme cubit for runtime theme switching
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Sabit App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

// Hamed Eslam