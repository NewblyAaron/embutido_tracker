import 'package:flutter/material.dart';

Future<String?> showEditUsernameDialog({
  required BuildContext context,
  required String currentUsername,
}) async {
  final controller = TextEditingController(text: currentUsername);

  return await showDialog<String>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Edit Username"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Username",
              hintText: "Enter new username",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text("Save"),
            ),
          ],
        ),
  );
}
