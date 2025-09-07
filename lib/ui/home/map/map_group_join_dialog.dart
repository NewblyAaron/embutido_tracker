import 'package:embutido_tracker/core/utils/validations.dart';
import 'package:flutter/material.dart';

class JoinForm extends StatefulWidget {
  const JoinForm({super.key});

  @override
  State<JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<JoinForm> {
  final _joinCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Join a group"),
        content: TextFormField(
          decoration: InputDecoration(labelText: "Join code"),
          controller: _joinCodeController,
          validator:
              (value) =>
                  Validations.hasInput(value, errorMessage: "Enter join code"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, _joinCodeController.value.text);
              }
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }
}
