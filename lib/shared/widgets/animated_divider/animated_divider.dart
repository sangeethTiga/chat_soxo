import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

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
  final String? title;
  final String? imageUrl;
  final int? chatId;
  const GroupCardWidget({super.key, this.title, this.imageUrl, this.chatId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateToSingleChat(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),

        child: Row(
          children: [
            ChatAvatar(name: title ?? '', size: 30, imageUrl: imageUrl),

            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title ?? '',
                        style: FontPalette.hW700S14.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                      5.horizontalSpace,
                      Text(
                        'send request to case review',
                        style: FontPalette.hW500S14.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    '3 Replied 4 Pending',
                    style: FontPalette.hW500S12.copyWith(
                      color: Color(0XFF166FF6),
                    ),
                  ),
                ],
              ),
            ),
            SvgPicture.asset('assets/icons/clock.svg'),
            3.horizontalSpace,
            const Text('45 min'),
          ],
        ),
      ),
    );
  }

  void _navigateToSingleChat(BuildContext context) {
    context.push(routeSingleChat, extra: {"title": title, 'chat_id': chatId});
  }
}
