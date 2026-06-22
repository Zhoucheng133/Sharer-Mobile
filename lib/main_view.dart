import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_sink/utils/controller.dart';
import 'package:local_sink/views/files_view.dart';
import 'package:local_sink/views/server_view.dart';
import 'package:local_sink/views/settings_view.dart';
import 'package:path/path.dart' as p;

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  final Controller controller=Get.find();
  final fileViewKey = GlobalKey<FilesViewState>();

  Widget? appBarLeading(){
    if(controller.page.value!=Pages.files) return null;
    if(controller.nowDir.value==controller.filesDir.value) return null;
    return IconButton(
      icon: FaIcon(
        FontAwesomeIcons.arrowLeft,
        size: 18,
      ),
      onPressed: (){
        controller.nowDir.value=p.dirname(controller.nowDir.value);
        fileViewKey.currentState?.getFiles();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(controller.page.value.name.tr),
          scrolledUnderElevation: 0.0,
          leading: appBarLeading(),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: FaIcon(
                FontAwesomeIcons.file,
                size: 18,
              ),
              label: 'files'.tr,
            ),
            NavigationDestination(
              icon: FaIcon(
                FontAwesomeIcons.server,
                size: 18,
              ),
              label: 'server'.tr,
            ),
            NavigationDestination(
              icon: FaIcon(
                FontAwesomeIcons.gear,
                size: 18,
              ),
              label: 'settings'.tr,
            ),
          ],
          selectedIndex: controller.page.value.index,
          onDestinationSelected: (int index){
            controller.page.value=Pages.values[index];
          },
        ),
        body: IndexedStack(
          index: controller.page.value.index,
          children: [
            FilesView(key: fileViewKey,),
            ServerView(),
            SettingsView(),
          ],
        ),
      ),
    );
  }
}