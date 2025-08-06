
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';

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
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0XFFE3E3E3)),
            ),
            4.horizontalSpace,
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '3',
                style: FontPalette.hW600S14.copyWith(
                  color: const Color(0XFF9C27B0),
                ),
              ),
            ),
            8.horizontalSpace,
            GestureDetector(
              onTap: onArrowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 35.h,
                width: 35.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFFEEF3F1),
                ),
                child: AnimatedBuilder(
                  animation: arrowAnimation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: (state.isArrow) == false
                          ? SvgPicture.asset('assets/icons/icon.svg')
                          : SvgPicture.asset('assets/icons/icon (1).svg'),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class GroupCardWidget extends StatelessWidget {
  const GroupCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MainPadding(
          bottom: 0,
          top: 16.h,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/mynaui_pin-solid.svg'),
              5.horizontalSpace,
              Image.asset('assets/images/Rectangle 1.png'),
              5.horizontalSpace,
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Anoop TS  ',
                    style: FontPalette.hW700S14.copyWith(
                      color: const Color(0XFF515978),
                    ),
                    children: [
                      TextSpan(
                        text: 'send request to case',
                        style: FontPalette.hW500S14.copyWith(
                          color: const Color(0XFF515978),
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              SvgPicture.asset('assets/icons/clock.svg'),
              5.horizontalSpace,
              const Text('45 min'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 34.w, top: 0.h, bottom: 0),
          child: Row(
            children: [
              Text(
                '3 Replayed , 4 Pending',
                style: FontPalette.hW500S12.copyWith(
                  color: const Color(0XFF166FF6),
                ),
              ),
              5.horizontalSpace,
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SvgPicture.asset('assets/icons/Eye.svg'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
