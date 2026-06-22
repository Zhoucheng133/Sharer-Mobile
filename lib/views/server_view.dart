import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_sink/utils/controller.dart';
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
    final interfaces = await NetworkInterface.list();
    for (final interface in interfaces) {
      final addresses = interface.addresses;
      final localAddresses = addresses.where((address) => !address.isLoopback && address.type.name=="IPv4");
      for (final localAddress in localAddresses) {
        setState(() {
          address=localAddress.address;
        });
        return;
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
          Text(
            "$address:8080",
            style: TextStyle(
              fontSize: 15
            ),
          ),
          const SizedBox(height: 20,),
          Obx(
            () => Switch(
              value: controller.running.value, 
              thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  // 开启状态下的图标
                  return const Icon(Icons.check);
                }
                // 关闭状态下的图标（如果不想显示图标，可以返回 null）
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
          )
        ],
      ),
    );
  }
}