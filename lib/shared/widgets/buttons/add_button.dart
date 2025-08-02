import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final Function onTap;
  final Icon? icon;
  final Color? color;
  final double? width;
  const AddButton({
    super.key,
    required this.onTap,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: width ?? 5),
      child: CircleAvatar(
        backgroundColor: color ?? Color(0xff40AA54),
        maxRadius: 14,
        child: Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              onTap();
            },
            icon: icon ?? Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
