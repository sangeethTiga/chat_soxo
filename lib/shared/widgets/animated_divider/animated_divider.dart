import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class AnimatedDividerCard extends StatelessWidget {
  final VoidCallback onArrowTap;
  final Animation<double> arrowAnimation;
  final String? count;

  const AnimatedDividerCard({
    super.key,
    required this.onArrowTap,
    required this.arrowAnimation,
    this.count,
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
              child: Text(count ?? '', style: FontPalette.hW600S14.copyWith()),
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

// class GroupCardWidget extends StatelessWidget {
//   final String? title;
//   final String? imageUrl;
//   final int? chatId;
//   const GroupCardWidget({super.key, this.title, this.imageUrl, this.chatId});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         _navigateToSingleChat(context);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),

//         child: Row(
//           children: [
//             ChatAvatar(name: title ?? '', size: 30, imageUrl: imageUrl),

//             12.horizontalSpace,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         title ?? '',
//                         style: FontPalette.hW700S14.copyWith(
//                           color: Colors.black87,
//                         ),
//                       ),
//                       5.horizontalSpace,
//                       Text(
//                         'send request to case review',
//                         style: FontPalette.hW500S14.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   4.verticalSpace,
//                   Text(
//                     '3 Replied 4 Pending',
//                     style: FontPalette.hW500S12.copyWith(
//                       color: Color(0XFF166FF6),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SvgPicture.asset('assets/icons/clock.svg'),
//             3.horizontalSpace,
//             const Text('45 min'),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToSingleChat(BuildContext context) {
//     context.push(routeSingleChat, extra: {"title": title, 'chat_id': chatId});
//   }
// }
class GroupCardWidget extends StatelessWidget {
  final String? title;
  final String? imageUrl;
  final int? chatId;
  final VoidCallback? onTap; // Add this callback

  const GroupCardWidget({
    super.key,
    this.title,
    this.imageUrl,
    this.chatId,
    this.onTap, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap == null ? null : onTap!();
      }, // Add tap functionality
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Your existing avatar and title implementation
            ChatAvatar(size: 40.h, name: title ?? '', imageUrl: imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Pinned Message',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.push_pin, size: 16.sp, color: Colors.blue[600]),
          ],
        ),
      ),
    );
  }
}
