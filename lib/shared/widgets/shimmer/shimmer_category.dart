import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soxo_chat/shared/constants/colors.dart';

class CategoryShimmerItem extends StatelessWidget {
  const CategoryShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(),
        height: 100.h,
        width: 72.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 64.h,
              width: 64.w,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(32.r),
              ),
            ),
            8.verticalSpace,
            Container(
              height: 10.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerChild extends StatelessWidget {
  const ShimmerChild({
    super.key,
    this.width,
    this.height,
    this.color = kWhite,
    this.heightFactor,
    this.widthFactor,
    this.seperator,
    this.count = 1,
    this.radius = 4,
    this.alignment = Alignment.center,
  });

  final double? height, width;
  final double? heightFactor, widthFactor;
  final int count;
  final Widget? seperator;
  final Color color;
  final double radius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          count,
          (index) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width,
                height: height,
                margin: EdgeInsets.only(top: 10.h, bottom: 10),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              seperator ?? 3.horizontalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
