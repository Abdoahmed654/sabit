import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_event.dart';
import 'package:sapit/router/app_router.dart';

class AuthListener extends StatelessWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthSuccess) {
          // Connect to WebSocket when user logs in
          context.read<ChatBloc>().add(ConnectWebSocketEvent(state.user.id));
          AppRouter.push("home");
        } else if (state is AuthLoggedOut) {
          // Disconnect WebSocket when user logs out
          context.read<ChatBloc>().add(DisconnectWebSocketEvent());
        }
      },
      child: child,
    );
  }
}
