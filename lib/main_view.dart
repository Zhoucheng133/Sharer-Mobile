import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sharer_mobile/components/sheet_item.dart';
import 'package:sharer_mobile/utils/controller.dart';
import 'package:sharer_mobile/utils/dialogs.dart';
import 'package:sharer_mobile/views/files_view.dart';
import 'package:sharer_mobile/views/server_view.dart';
import 'package:sharer_mobile/views/settings_view.dart';

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

  Future<void> addFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);
    if (result == null) return;

    final targetDir = controller.nowDir.value;
    
    for (final path in result.paths) {
      if (path == null) continue;
      final file = File(path);
      final fileName = p.basename(path);
      final targetPath = p.join(targetDir, fileName);
      try {
        await file.copy(targetPath);
      } catch (e) {
        if(context.mounted){
          showOkDialog(context, "error".tr, e.toString());
        }
      }
    }

    fileViewKey.currentState?.getFiles();
  }

  Future<void> addImage(BuildContext context) async {
    final picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) return;

    for (final image in images) {
      final fileName = image.name;
      final destPath = p.join(controller.nowDir.value, fileName);
      await File(image.path).copy(destPath);
    }
    fileViewKey.currentState?.getFiles();
  }

  Future<void> addDir(BuildContext context) async {
    final dirName = await showInputDialog(context, title: 'mkdir'.tr, hint: '', initialValue: '', okText: "create");

    if (dirName == null || dirName.trim().isEmpty) return;
    final newDir = Directory(p.join(controller.nowDir.value, dirName.trim()));
     if (await newDir.exists()) {
      if (context.mounted) {
        await showOkDialog(context, "error".tr, "dirExists".tr);
      }
      return;
    }

    await newDir.create(recursive: true);
    fileViewKey.currentState?.getFiles();
  }

  Future<void> addHandler(BuildContext conntext) async {
    await showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) => Column(
        mainAxisSize: .min,
        children: [
          SheetItem(label: "fromFile".tr, iconData: FontAwesomeIcons.file, callback: ()=>addFile(context)),
          SheetItem(label: "fromGallery".tr, iconData: FontAwesomeIcons.image, callback: ()=>addImage(context)),
          SheetItem(label: "mkdir".tr, iconData: FontAwesomeIcons.folder, callback: ()=>addDir(context)),
          SizedBox(height: MediaQuery.of(context).padding.bottom,),
        ],
      )
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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
        floatingActionButton: controller.page.value==Pages.files ? FloatingActionButton(
          child: FaIcon(
            FontAwesomeIcons.plus,
            size: 18,
          ),
          onPressed: ()=>addHandler(context)
        ) : null,
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