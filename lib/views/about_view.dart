import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutView extends StatefulWidget {

  final String version;

  const AboutView({super.key, required this.version});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about'.tr),
      ),
    );
  }
}