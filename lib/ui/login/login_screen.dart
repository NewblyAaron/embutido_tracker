import 'package:embutido_tracker/domain/repositories/auth_repository.dart';
import 'package:embutido_tracker/ui/login/login_card.dart';
import 'package:embutido_tracker/ui/login/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (context) => LoginViewModel(auth: context.read<AuthService>()),
      builder: (context, child) => _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  @override
  State<_LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<_LoginScreenBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/embutido.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
            child: LoginCard(),
          ),
        ),
      ),
    );
  }
}
