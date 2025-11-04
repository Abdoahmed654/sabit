import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/widgets/app_text_field.dart';
import 'package:sapit/core/widgets/primary_button.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_event.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';
import 'package:sapit/router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0E0E), Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthSuccess) {
              // Navigate to home on success
              AppRouter.push("home");
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text("Welcome Back 👋",
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                )),
                const SizedBox(height: 8),
                const Text("Login to continue your journey",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                AppTextField(controller: emailCtrl, hint: "Email"),
                const SizedBox(height: 16),
                AppTextField(controller: passwordCtrl, hint: "Password", obscure: true),
                const SizedBox(height: 24),
                state is AuthLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                    : PrimaryButton(
                        text: "Login",
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                LoginEvent(emailCtrl.text, passwordCtrl.text),
                              );
                        }),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => AppRouter.push("signup"),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
