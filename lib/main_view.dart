import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sharer_mobile/components/sheet_item.dart';
import 'package:sharer_mobile/utils/controller.dart';
import 'package:sharer_mobile/utils/dialogs.dart';
import 'package:sharer_mobile/utils/server.dart';
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

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list()) {
      final targetPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        await entity.copy(targetPath);
      }
    }
  }

  Future<void> pasteItems(BuildContext context) async {
    final items = controller.copyMoveItem.value.items;
    final type = controller.copyMoveItem.value.type;
    if (type == null || items.isEmpty) return;

    final targetDir = controller.nowDir.value;

    if (type == CopyMoveType.copy && items.every((i) => p.dirname(i.path) == targetDir)) {
      if (context.mounted) {
        await showOkDialog(context, "error".tr, "sameLocation".tr);
      }
      return;
    }

    for (final item in items) {
      final fileName = p.basename(item.path);
      final targetPath = p.join(targetDir, fileName);

      try {
        if (type == CopyMoveType.copy) {
          if (item.isDir) {
            await _copyDirectory(Directory(item.path), Directory(targetPath));
          } else {
            await File(item.path).copy(targetPath);
          }
        } else {
          if (p.dirname(item.path) == targetDir) continue;
          if (item.isDir) {
            await Directory(item.path).rename(targetPath);
          } else {
            await File(item.path).rename(targetPath);
          }
        }
      } catch (e) {
        if (context.mounted) {
          await showOkDialog(context, "error".tr, e.toString());
        }
        return;
      }
    }

    controller.copyMoveItem.value.type = null;
    controller.copyMoveItem.value.items = [];
    controller.copyMoveItem.refresh();
    fileViewKey.currentState?.getFiles();
  }

  Future<void> deleteSelected(BuildContext context) async {
    final selected = controller.multiSelect.value.selected;
    if (selected.isEmpty) return;

    final names = selected.map((e) => p.basename(e.path)).join(', ');
    final confirm = await showOkCancelDialog(
      context, "delete".tr,
      "${'delete'.tr}: $names",
      okText: "delete".tr,
    );
    if (!confirm) return;

    for (final item in selected) {
      try {
        if (item.isDir) {
          await Directory(item.path).delete(recursive: true);
        } else {
          await File(item.path).delete();
        }
      } catch (e) {
        if (context.mounted) {
          await showOkDialog(context, "error".tr, e.toString());
        }
        return;
      }
    }

    controller.multiSelect.value.selected=[];
    controller.multiSelect.value.multiSelect=false;
    controller.multiSelect.refresh();
    fileViewKey.currentState?.getFiles();
  }

  void permissionHandler() async {
    if(!controller.initNetwork.value){
      await ping("https://example.org");
      final prefs=await SharedPreferences.getInstance();
      prefs.setBool("initNetwork", true);
    }
  }

  @override
  void initState() {
    super.initState();
    permissionHandler();
  }

  void handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.page.value != Pages.files) {
            handleBack();
            return;
          }
          if (controller.nowDir.value == controller.filesDir.value) {
            handleBack();
            return;
          }
          controller.nowDir.value=p.dirname(controller.nowDir.value);
          fileViewKey.currentState?.getFiles();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(controller.page.value.name.tr),
            scrolledUnderElevation: 0.0,
            leading: appBarLeading(),
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: controller.page.value==Pages.files && controller.multiSelect.value.multiSelect ? [
              Padding(
                padding: .only(right: 10),
                child: PopupMenuButton(
                  onSelected: (value) {
                    switch (value) {
                      case 0:
                        controller.multiSelect.value.selected=[];
                        controller.multiSelect.value.multiSelect=false;
                        controller.multiSelect.refresh();
                        break;
                      case 1:
                        controller.copyMoveItem.value.type=CopyMoveType.copy;
                        controller.copyMoveItem.value.items=[...controller.multiSelect.value.selected];
                        controller.copyMoveItem.refresh();
                        controller.multiSelect.value.selected=[];
                        controller.multiSelect.value.multiSelect=false;
                        controller.multiSelect.refresh();
                        break;
                      case 2:
                        controller.copyMoveItem.value.type=CopyMoveType.move;
                        controller.copyMoveItem.value.items=[...controller.multiSelect.value.selected];
                        controller.copyMoveItem.refresh();
                        controller.multiSelect.value.selected=[];
                        controller.multiSelect.value.multiSelect=false;
                        controller.multiSelect.refresh();
                        break;
                      case 3:
                        deleteSelected(context);
                        break;
                      default:
                        break;
                    }
                  },
                  icon: Icon(Icons.more_vert_rounded),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Text('cancel'.tr),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Text('copy'.tr),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text('move'.tr),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text('delete'.tr),
                    ),
                  ]
                ),
              )
            ] : null,
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
            child: controller.copyMoveItem.value.type==null ? FaIcon(
              FontAwesomeIcons.plus,
              size: 18,
            ) : FaIcon(
              FontAwesomeIcons.paste
            ),
            onPressed: (){
              if(controller.copyMoveItem.value.type==null){
                addHandler(context);
              }else{
                pasteItems(context);
              }
            }
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
      ),
    );
  }
}