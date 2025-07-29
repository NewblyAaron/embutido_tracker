import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final String submitLabel;
  final String? errorMessage;

  const AuthForm({
    super.key,
    required this.onSubmit,
    required this.submitLabel,
    this.errorMessage,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  void _handleSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _formKey.currentState?.save();
    widget.onSubmit(_email.trim(), _password);
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorMessage;

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(error, style: TextStyle(color: Colors.red)),
            ),
          TextFormField(
            decoration: InputDecoration(labelText: "Email"),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter email";
              if (!value.contains('@')) return "Enter a valid email";
              return null;
            },
            onSaved: (value) => _email = value ?? "",
          ),
          TextFormField(
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Enter password";
              if (value.length < 6) return "Password too short";
              return null;
            },
            onSaved: (value) => _password = value ?? "",
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(widget.submitLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
