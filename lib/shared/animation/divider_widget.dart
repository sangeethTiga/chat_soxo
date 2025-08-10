import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class AnimatedDividerCard extends StatelessWidget {
  final VoidCallback onArrowTap;
  final Animation<double> arrowAnimation;

  const AnimatedDividerCard({
    super.key,
    required this.onArrowTap,
    required this.arrowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onArrowTap,
      child: Container(
        padding: EdgeInsets.only(left: 0.w, right: 12, top: 0, bottom: 0),
        child: Row(
          children: [
            const Expanded(child: Divider()),
            2.horizontalSpace,
            AnimatedBuilder(
              animation: arrowAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: arrowAnimation.value * 6.28,
                  child: Container(
                    height: 25.h,
                    width: 25.w,
                    decoration: BoxDecoration(
                      color: Color(0XFFEEF3F1),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SvgPicture.asset('assets/icons/icon.svg'),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
