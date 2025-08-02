import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

Widget dividerWidget({double? height, Color? color}) {
  return Divider(color: color ?? kPrimaryColor1, thickness: height ?? 1.h);
}
