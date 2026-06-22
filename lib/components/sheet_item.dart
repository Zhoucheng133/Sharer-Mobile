import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SheetItem extends StatefulWidget {

  final String label;
  final FaIconData iconData;
  final VoidCallback callback;

  const SheetItem({super.key, required this.label, required this.iconData, required this.callback});

  @override
  State<SheetItem> createState() => _SheetItemState();
}

class _SheetItemState extends State<SheetItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      leading: FaIcon(
        widget.iconData,
        size: 18,
      ),
      onTap: () {
        Navigator.pop(context);
        widget.callback();
      },
    );
  }
}