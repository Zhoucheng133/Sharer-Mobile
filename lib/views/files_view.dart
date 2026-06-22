import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:local_sink/utils/controller.dart';
import 'package:local_sink/utils/types.dart';
import 'package:path/path.dart' as p;

class FilesView extends StatefulWidget {
  const FilesView({super.key});

  @override
  State<FilesView> createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {

  bool loading=true;
  List<FileItem> files=[];
  final Controller controller = Get.find();

  void getFiles() async {
    final dir = Directory(controller.filesDir.value);
    if(await dir.exists()){
      Stream<FileSystemEntity> fileList = dir.list(recursive: false);
      await for (FileSystemEntity entity in fileList) {
        final filePath=entity.path;
        files.add(FileItem(filePath, entity is Directory));
      }
      files.sort((a, b) {
        if (a.isDir && !b.isDir) {
          return -1; 
        }
        if (!a.isDir && b.isDir) {
          return 1;
        }
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
    }
    setState(() {
      loading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Center(child: CircularProgressIndicator()) : files.isEmpty ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "noFiles".tr,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          IconButton(
            onPressed: (){}, 
            icon: FaIcon(
              FontAwesomeIcons.arrowRotateRight,
              size: 18,
            )
          )
        ],
      ),
    ) : ListView.builder(
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) => ListTile(
        title: Text(p.basename(files[index].path)),
        subtitle: Text(files[index].path),
      )
    );
  }
}