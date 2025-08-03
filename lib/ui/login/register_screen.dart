import 'package:embutido_tracker/domain/services/auth_service.dart';
import 'package:embutido_tracker/ui/login/register_card.dart';
import 'package:embutido_tracker/ui/login/register_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterViewModel>(
      create: (context) => RegisterViewModel(auth: context.read<AuthService>()),
      builder: (context, child) => _RegisterScreenBody(),
    );
  }
}

class _RegisterScreenBody extends StatefulWidget {
  const _RegisterScreenBody();

  @override
  State<_RegisterScreenBody> createState() => _RegisterScreenBodyState();
}

class _RegisterScreenBodyState extends State<_RegisterScreenBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up")),
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
            child: RegisterCard(),
          ),
        ),
      ),
    );
  }
}
