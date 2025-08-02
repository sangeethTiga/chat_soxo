import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/buttons/check_box.dart';

Widget buildChatContacts(
  String initials,
  Color avatarColor,
  String name,
  String message,
  String time,
  int unreadCount,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.only(left: 6.w, right: 8.w, bottom: 6.h, top: 6.h),
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: avatarColor,
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
          child: Center(
            child: Text(
              initials,
              style: FontPalette.hW700S14.copyWith(color: kWhite),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(child: Text(name, style: FontPalette.hW600S14)),
        CustomCheckBox(isSelected: true),
      ],
    ),
  );
}
