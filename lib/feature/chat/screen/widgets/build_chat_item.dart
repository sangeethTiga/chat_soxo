import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

Widget buildChatItem({
  String? name,
  String? message,
  String? time,
  int? unreadCount,
  String? imageUrl,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.only(left: 0.w, right: 8.w, bottom: 6.h, top: 6.h),
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        CachedChatAvatar(name: name ?? '', size: 40, imageUrl: imageUrl),

        12.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? '', style: FontPalette.hW600S13),
              SizedBox(height: 4),
              Text(
                message ?? '',
                style: FontPalette.hW400S12.copyWith(color: Color(0XFFADB5BD)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time ?? '',
              style: TextStyle(color: Color(0XFFA4A4A4), fontSize: 12),
            ),
            if ((unreadCount ?? 0) > 0) ...[
              10.verticalSpace,
              Container(
                alignment: Alignment.center,
                height: 20.h,
                width: 20.w,
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0XFFD2D5F9),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: FontPalette.hW500S10.copyWith(
                    color: Color(0xFF001569),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

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
