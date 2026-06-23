import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sharer_mobile/components/breadcrumb_bar.dart';
import 'package:sharer_mobile/components/file_item.dart';
import 'package:sharer_mobile/utils/controller.dart';
import 'package:sharer_mobile/utils/types.dart';

class FilesView extends StatefulWidget {
  const FilesView({super.key});

  @override
  State<FilesView> createState() => FilesViewState();
}

class FilesViewState extends State<FilesView> {

  bool loading=true;
  List<FileType> files=[];
  final Controller controller = Get.find();

  Future<void> getFiles() async {
    setState(() {
      loading=true;
    });
    final dir = Directory(controller.nowDir.value);
    if(await dir.exists()){

      List<FileType> tmpList=[];

      Stream<FileSystemEntity> fileList = dir.list(recursive: false);
      await for (FileSystemEntity entity in fileList) {
        final filePath = entity.path;
        final int size;
        if (entity is Directory) {
          size = 0;
        } else {
          final stat = await entity.stat();
          size = stat.size;
        }
        tmpList.add(FileType(filePath, entity is Directory, size));
      }
      tmpList.sort((a, b) {
        if (a.isDir && !b.isDir) {
          return -1; 
        }
        if (!a.isDir && b.isDir) {
          return 1;
        }
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });
      setState(() {
        files=tmpList;
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

  void onChanged(String path){
    controller.nowDir.value=path;
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Center(child: CircularProgressIndicator()) : CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BreadcrumbBar(
            rootDir: controller.filesDir.value,
            currentPath: controller.nowDir.value, 
            refresh: () => getFiles(),
          ),
        ),
        SliverFillRemaining(
          child: files.isEmpty ? Center(
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
                  onPressed: getFiles, 
                  icon: FaIcon(
                    FontAwesomeIcons.arrowRotateRight,
                    size: 18,
                  )
                )
              ],
            ),
          ) : RefreshIndicator(
            onRefresh: () => getFiles(),
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) => FileItem(
                file: files[index],
                refresh: getFiles,
                onChanged: (value) => onChanged(value),
              ),
            ),
          ),
        ),
      ],
    );
  }
}