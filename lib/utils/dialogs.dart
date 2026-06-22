import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showOkDialog(BuildContext context, String title, String content) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          ElevatedButton(
            child: Text("ok".tr),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}