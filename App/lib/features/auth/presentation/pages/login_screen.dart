import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/widgets/app_text_field.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_event.dart';
import 'package:sapit/features/auth/presentation/widgets/auth_footer.dart';
import 'package:sapit/features/auth/presentation/widgets/auth_form_container.dart';
import 'package:sapit/features/auth/presentation/widgets/auth_header.dart';
import 'package:sapit/features/auth/presentation/widgets/auth_layout.dart';
import 'package:sapit/features/auth/presentation/widgets/auth_listener.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    context.read<AuthBloc>().add(LoginEvent(emailCtrl.text, passwordCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: AuthListener(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const AuthHeader(
              title: "Welcome Back 👋",
              subTitle: "Login to continue your journey",
            ),
            AuthFormContainer(
              buttonText: "Login",
              onSubmit: () => _onLogin(context),
              children: [
                AppTextField(controller: emailCtrl, hint: "Email"),
                const SizedBox(height: 16),
                AppTextField(controller: passwordCtrl, hint: "Password", obscure: true),
              ],
            ),
            const SizedBox(height: 12),
            const AuthFooter(to: "signup", buttonText: "Don't have an account? Sign up"),
          ],
        ),
      ),
    );
  }
}
