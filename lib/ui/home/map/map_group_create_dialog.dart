import 'package:embutido_tracker/core/utils/validations.dart';
import 'package:flutter/material.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({super.key});

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Create new group"),
        content: TextFormField(
          decoration: InputDecoration(labelText: "Group Name"),
          controller: _nameController,
          validator:
              (value) =>
                  Validations.hasInput(value, errorMessage: "Enter group name"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, _nameController.value.text);
              }
            },
            child: Text("Create"),
          ),
        ],
      ),
    );
  }
}
