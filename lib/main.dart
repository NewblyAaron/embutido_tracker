import 'package:embutido_tracker/ui/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EmbutidoApp());
}

class EmbutidoApp extends StatelessWidget {
  const EmbutidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: LoginScreen()));
  }
}
