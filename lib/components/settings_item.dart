import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsItem extends StatefulWidget {

  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final FaIconData? iconData;

  const SettingsItem({super.key, required this.label, this.subtitle, this.trailing, required this.onTap, this.iconData});

  @override
  State<SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<SettingsItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.iconData==null ? null : FaIcon(
        widget.iconData,
        size: 18,
      ),
      title: Text(widget.label),
      subtitle: widget.subtitle==null ? null : Text(widget.subtitle!),
      subtitleTextStyle: TextStyle(
        color: Colors.grey
      ),
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}