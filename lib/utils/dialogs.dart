import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showOkDialog(BuildContext context, String title, String content, {String okText="ok"}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          ElevatedButton(
            child: Text(okText.tr),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<bool> showOkCancelDialog(BuildContext context, String title, String content, {String okText="ok"}) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text("cancel".tr),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          ElevatedButton(
            child: Text(okText.tr),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          )
        ]
      );
    }
  ) ?? false;
}

Future<String?> showInputDialog(BuildContext context, {
  required String title, 
  required String hint,
  required String initialValue,
  String okText="ok", 
  String cancelText="cancel"
}) async {
  final controller = TextEditingController(text: initialValue);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            child: Text(cancelText.tr),
            onPressed: () => Navigator.of(context).pop(null)
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text), 
            child: Text(okText.tr)
          )
        ]
      );
    }
  );
}