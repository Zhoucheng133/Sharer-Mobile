import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_sink/utils/controller.dart';
import 'package:local_sink/utils/dialogs.dart';
import 'package:local_sink/utils/server.dart';

class ServerView extends StatefulWidget {
  const ServerView({super.key});

  @override
  State<ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<ServerView> {

  final Controller controller = Get.find();
  final server = Server();

  String address="";

  Future<void> getAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    
    const wifiNames = {'en0', 'wlan0'};
    
    for (final interface in interfaces) {
      if (!wifiNames.contains(interface.name)) continue;
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          setState(() => this.address = address.address);
          return;
        }
      }
    }
    
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          setState(() => this.address = address.address);
          return;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisSize: .min,
            spacing: 10,
            children: [
              FaIcon(
                FontAwesomeIcons.towerBroadcast,
                size: 18,
              ),
              Text(
                "shareFiles".tr,
                style: TextStyle(
                  fontSize: 16
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          GestureDetector(
            onTap: () async {
              await FlutterClipboard.copy("$address:8080");
              if(context.mounted){
                showOkDialog(context, "copySuccess".tr, "copySharedLinkSuccess".tr);
              }
            },
            child: Text(
              "$address:8080",
              style: TextStyle(
                fontSize: 15
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Obx(
            () => Transform.scale(
              scale: 1.2,
              child: Switch(
                value: controller.running.value, 
                thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Icon(Icons.check);
                  }
                  return const Icon(Icons.close);
                }),
                onChanged: (val){
                  controller.running.value=val;
                  if(val){
                    server.run("", "", "8080", controller.filesDir.value);
                  }else{
                    server.stop();
                  }
                }
              ),
            ),
          )
        ],
      ),
    );
  }
}