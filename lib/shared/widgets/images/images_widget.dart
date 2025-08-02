import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

Widget imageShow({String? image, double? width, double? height}) {
  return CachedNetworkImage(
    height: width ?? 64.h,
    width: height ?? 96.w,
    imageUrl: image ?? '',
    fit: BoxFit.cover,
    errorWidget: (context, url, error) =>
        Icon(Icons.photo, size: height ?? 74.h, color: kGrey400),
  );
}
