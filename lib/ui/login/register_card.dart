import 'package:embutido_tracker/ui/login/auth_form.dart';
import 'package:embutido_tracker/ui/login/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterCard extends StatelessWidget {
  const RegisterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthForm(
            onSubmit:
                (email, password) => context
                    .read<RegisterViewModel>()
                    .signUp(email: email, password: password)
                    .then((success) {
                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    }),
            submitLabel: "Register",
            errorMessage: context.select<RegisterViewModel, String?>(
              (vm) => vm.error,
            ),
          ),
        ],
      ),
    );
  }
}
