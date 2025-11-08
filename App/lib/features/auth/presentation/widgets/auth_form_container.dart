import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/widgets/primary_button.dart';
import 'package:sapit/features/auth/presentation/state/auth_bloc.dart';
import 'package:sapit/features/auth/presentation/state/auth_state.dart';

class AuthFormContainer extends StatelessWidget {
  final List<Widget> children;
  final String buttonText;
  final VoidCallback onSubmit;

  const AuthFormContainer({
    super.key,
    required this.children,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...children,
            const SizedBox(height: 24),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : PrimaryButton(
                    text: buttonText,
                    onPressed: onSubmit,
                  ),
          ],
        );
      },
    );
  }
}
