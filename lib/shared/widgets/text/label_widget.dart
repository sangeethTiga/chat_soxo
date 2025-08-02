import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

Widget labelWidget({
  required String name,
  required VoidCallback onTap,
  bool isSeeAll = false,
  double? height,
}) {
  return Padding(
    padding: EdgeInsets.only(top: height ?? 12.h, left: 12.w, right: 12.w),
    child: GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: FontPalette.hW800S16),
          Spacer(),
          if (isSeeAll == false) ...{
            Text(
              'See all',
              style: FontPalette.hW700S13.copyWith(color: kPrimaryColor),
            ),
            4.horizontalSpace,
            SvgPicture.asset('assets/icons/Frame 8.svg', color: kPrimaryColor),
          },
        ],
      ),
    ),
  );
}
