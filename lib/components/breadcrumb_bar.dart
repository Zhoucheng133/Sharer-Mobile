import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sharer_mobile/utils/controller.dart';

class BreadcrumbBar extends StatefulWidget {
  final String rootDir;
  final String currentPath;
  final VoidCallback refresh;

  const BreadcrumbBar({super.key, required this.rootDir, required this.currentPath, required this.refresh});

  @override
  State<BreadcrumbBar> createState() => _BreadcrumbBarState();
}

class _BreadcrumbBarState extends State<BreadcrumbBar> {

  final controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    final relative = widget.currentPath.replaceFirst(widget.rootDir, '');
    final parts = relative.split(Platform.pathSeparator).where((e) => e.isNotEmpty).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: parts.isEmpty ? null : (){
              controller.nowDir.value = widget.rootDir;
              widget.refresh();
            },
            child: Icon(
              Icons.home_outlined,
              size: 18,
              color: parts.isEmpty ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
            ),
          ),
          ...List.generate(parts.length, (i) {
            final isLast = i == parts.length - 1;
            final segPath = widget.rootDir + Platform.pathSeparator + parts.sublist(0, i + 1).join(Platform.pathSeparator);

            return Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.chevron_right, size: 16),
                ),
                GestureDetector(
                  onTap: isLast ? null : (){
                    controller.nowDir.value = segPath;
                    widget.refresh();
                  },
                  child: Text(
                    parts[i],
                    style: TextStyle(
                      fontSize: 13,
                      color: isLast
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}