import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

Widget buildTab(String text, bool isSelected, {double? width}) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.symmetric(horizontal: width ?? 0, vertical: 0),
    decoration: BoxDecoration(
      color: isSelected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(28.r),
      border: Border.all(color: isSelected ? kPrimaryColor : Color(0XFFE3E3E3)),
    ),
    child: Text(
      text,
      style: FontPalette.hW500S12.copyWith(
        color: isSelected ? kPrimaryColor : Color(0XFF0F1828),
      ),
    ),
  );
}
