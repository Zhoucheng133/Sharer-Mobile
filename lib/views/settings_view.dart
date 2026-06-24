import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharer_mobile/components/settings_item.dart';
import 'package:sharer_mobile/utils/controller.dart';
import 'package:sharer_mobile/utils/dialogs.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  
  final controller = Get.find<Controller>();
  late SharedPreferences prefs;

  Future<void> changePort(BuildContext context) async {
    final String? port=await showInputDialog(
      context, 
      title: "port".tr, 
      hint: "", 
      initialValue: controller.port.toString(),
      isNumber: true
    );
    if(port!=null){
      if(int.parse(port)<1024 || int.parse(port)>65535){
        if(context.mounted){
          await showOkDialog(context, "error".tr, "port_range".tr);
        }
        return;
      }
      controller.port.value=port;
      prefs.setString("port", port);
    }
  }

  void changeAuth(BuildContext context) async {
    AuthSetting? authSetting=await showAuthDialog(
      context, 
      username: controller.username.value, 
      password: controller.password.value,
      useAuth: controller.useAuth.value
    );

    if(authSetting==null) return;
    controller.useAuth.value=authSetting.useAuth;
    controller.username.value=authSetting.username;
    controller.password.value=authSetting.password;
    prefs.setBool("useAuth", authSetting.useAuth);
    prefs.setString("username", authSetting.username);
    prefs.setString("password", authSetting.password);
  }

  Future<void> init() async {
    prefs=await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        children: [
          SettingsItem(
            label: "port".tr, 
            onTap: ()=>changePort(context), 
            subtitle: controller.port.toString(),
            iconData: FontAwesomeIcons.chartDiagram,
          ),
          SettingsItem(
            label: "auth".tr, 
            onTap: ()=>changeAuth(context),
            subtitle: controller.useAuth.value ? controller.username.value : "noAuth".tr,
            iconData: FontAwesomeIcons.fingerprint,
          )
        ],
      ),
    );
  }
}