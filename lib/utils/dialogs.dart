import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthSetting{
  bool useAuth;
  String username;
  String password;
  AuthSetting({this.useAuth=false, this.username="", this.password=""});
}

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
  String cancelText="cancel",
  bool isNumber=false
}) async {
  final controller = TextEditingController(text: initialValue);
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          keyboardType: isNumber ? TextInputType.number : null,
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

Future<AuthSetting?> showAuthDialog(BuildContext context, {
  required bool useAuth,
  required String username,
  required String password,
}) async {

  bool value = useAuth;
  final usernameInput = TextEditingController(text: username);
  final passwordInput = TextEditingController(text: password);

  return await showDialog(
    context: context, 
    builder: (BuildContext context) => AlertDialog(
      title: Text("auth".tr),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState)=>Column(
          mainAxisSize: .min,
          spacing: 10,
          children: [
            CheckboxListTile(
              title: Text("useAuth".tr),
              value: value,
              onChanged: (val) => setState(() => value = val!),
            ),
            if(value) Column(
              spacing: 10,
              children: [
                TextField(
                  controller: usernameInput,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("username".tr)
                  ),
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                TextField(
                  controller: passwordInput,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("password".tr),
                  ),
                  obscureText: true,
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
              ],
            ),
          ],
        )
      ),
      actions: [
        TextButton(
          onPressed: ()=>Navigator.of(context).pop(null),
          child: Text("cancel".tr)
        ),
        ElevatedButton(
          onPressed: ()=>Navigator.of(context).pop(AuthSetting(
            useAuth: value,
            username: usernameInput.text,
            password: passwordInput.text
          )),
          child: Text("ok".tr)
        )
      ],
    )
  );
}