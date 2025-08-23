import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/buttons/check_box.dart';

Widget buildChatContacts(
  String name,
  VoidCallback? onTap, {
  bool? isShow = false,
  bool isSelected = false,
  String? image,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left: 0.w, right: 0.w, bottom: 6.h, top: 6.h),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CachedChatAvatar(name: name ?? '', size: 46, imageUrl: image),

          12.horizontalSpace,
          Expanded(child: Text(name, style: FontPalette.hW600S14)),
          if (isShow == false) CustomCheckBox(isSelected: isSelected),
        ],
      ),
    ),
  );
}
