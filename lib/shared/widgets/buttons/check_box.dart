import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

class CustomCheckBox extends StatelessWidget {
  final bool? isSelected;
  final Function()? onTap;
  const CustomCheckBox({super.key, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap?.call();
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w, top: 5.h),
        height: 20.h,
        width: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected == true ? kPrimaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected == true ? kPrimaryColor : Color(0XFFCBD7D4),
          ),
        ),
        child: isSelected == true
            ? Icon(Icons.check, size: 15.h, color: kWhite)
            : null,
      ),
    );
  }
}
