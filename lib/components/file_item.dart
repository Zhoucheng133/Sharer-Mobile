import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_sink/components/sheet_item.dart';
import 'package:local_sink/utils/dialogs.dart';
import 'package:local_sink/utils/types.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class FileItem extends StatefulWidget {

  final FileType file;
  final VoidCallback refresh;
  final ValueChanged onChanged;

  const FileItem({super.key, required this.file, required this.refresh, required this.onChanged});

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem> {

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Future<void> share() async {
    final file = XFile(widget.file.path);
    await SharePlus.instance.share(
      ShareParams(files: [file]),
    );
  }

  Future<void> deleteDirectory() async {
    final dir = Directory(widget.file.path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> deleteFile() async {
    final file = File(widget.file.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> delete(BuildContext context) async {
    final confirm = await showOkCancelDialog(context, "delete".tr, "${'delete'.tr}: ${p.basename(widget.file.path)}", okText: "delete".tr);
    if(!confirm) return;
    try {
      if(widget.file.isDir){
        await deleteDirectory();
      } else {
        await deleteFile();
      }
    } catch (e) {
      if(context.mounted){
        showOkDialog(context, "error".tr, e.toString());
      }
    }
    widget.refresh();
  }

  Future<void> rename(BuildContext context) async {
    final newName = await showInputDialog(context, title: "rename".tr, hint: "new_name".tr, initialValue: p.basename(widget.file.path), okText: "rename".tr);
    if (newName == null || newName.trim().isEmpty) return;

    final dir = p.dirname(widget.file.path);
    final newPath = p.join(dir, newName.trim());

    try {
      if (widget.file.isDir) {
        await Directory(widget.file.path).rename(newPath);
      } else {
        await File(widget.file.path).rename(newPath);
      }
      widget.refresh();
    } catch (e) {
      if(context.mounted){
        showOkDialog(context, "error".tr, e.toString());
      }
    }
  }

  void handleClick(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      builder: (BuildContext context) => Column(
        mainAxisSize: .min,
        children: [
          SheetItem(label: "share".tr, iconData: FontAwesomeIcons.shareFromSquare, callback: share),
          SheetItem(label: "rename".tr, iconData: FontAwesomeIcons.penToSquare, callback: () => rename(context),),
          SheetItem(label: "delete".tr, iconData: FontAwesomeIcons.trash, callback: () => delete(context),),
          SizedBox(height: MediaQuery.of(context).padding.bottom,),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(p.basename(widget.file.path)),
      subtitle: Text(widget.file.isDir ? "dir".tr : formatFileSize(widget.file.size)),
      leading: widget.file.isDir ? FaIcon(FontAwesomeIcons.folder) : FaIcon(FontAwesomeIcons.file),
      onLongPress: () => handleClick(context),
      onTap: () async {
        if(widget.file.isDir){
          widget.onChanged(widget.file.path);
        }else{
          await OpenFile.open(widget.file.path);
        }
      },
    );
  }
}