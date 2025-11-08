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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if ([nameCtrl, emailCtrl, passwordCtrl].any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterEvent(emailCtrl.text, passwordCtrl.text, nameCtrl.text),
        );
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
              title: "Create Account 🌟",
              subTitle: "Start your journey to good deeds",
            ),
            AuthFormContainer(
              buttonText: "Sign Up",
              onSubmit: () => _onRegister(context),
              children: [
                AppTextField(controller: nameCtrl, hint: "Display Name"),
                const SizedBox(height: 16),
                AppTextField(controller: emailCtrl, hint: "Email"),
                const SizedBox(height: 16),
                AppTextField(controller: passwordCtrl, hint: "Password", obscure: true),
              ],
            ),
            const SizedBox(height: 12),
            const AuthFooter(to: "login", buttonText: "Already have an account? Login"),
          ],
        ),
      ),
    );
  }
}
