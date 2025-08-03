import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

PreferredSizeWidget buildAppBar(
  BuildContext context,
  Map<String, dynamic>? arguments, {
  bool? isLeading = false,
  String? title,
  double? height,
  int? notificationCount,
  VoidCallback? onNotificationTap,
  VoidCallback? onBackPressed,
  bool? isNotification = false,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(height ?? 55.h),
    child: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                if (isLeading == true) ...[
                  Container(
                    padding: EdgeInsets.only(left: 5.w),
                    alignment: Alignment.center,
                    height: 39.h,
                    width: 39.w,
                    decoration: const BoxDecoration(
                      color: kWhite,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],

                Expanded(
                  child: Text(
                    title ?? '',
                    style: FontPalette.hW400S18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isNotification == false)
                  _buildNotificationBell(
                    notificationCount: notificationCount ?? 5,
                    onTap: onNotificationTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildNotificationBell({
  required int notificationCount,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        SvgPicture.asset('assets/icons/bell.svg', width: 24.w, height: 24.h),
        if (notificationCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE42168),
                shape: BoxShape.circle,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: FontPalette.hW400S8.copyWith(
                  color: kWhite,
                  fontSize: notificationCount > 99 ? 6.sp : 8.sp,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// Widget _buildCircularButton({
//   required IconData icon,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: EdgeInsets.all(8.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Icon(icon, size: 20.sp, color: Colors.black87),
//     ),
//   );
// }

PreferredSizeWidget buildAppBarWithProfile(
  BuildContext context,
  Map<String, dynamic>? arguments, {
  final String? title,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(65.h),
    child: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 5.w),
                  alignment: Alignment.center,
                  height: 39.h,
                  width: 39.w,
                  decoration: const BoxDecoration(
                    color: kWhite,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ),
                6.horizontalSpace,
                ChatAvatar(name: title ?? '', size: 40.h),
                6.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.verticalSpace,
                    Text(title ?? '', style: FontPalette.hW400S18),
                    1.verticalSpace,

                    Row(
                      children: [
                        Container(
                          height: 8.h,
                          width: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF68D391),
                            shape: BoxShape.circle,
                          ),
                        ),
                        5.horizontalSpace,
                        Text('Online', style: FontPalette.hW600S12),
                      ],
                    ),
                  ],
                ),
                // Stack(
                //   children: [
                //     SvgPicture.asset('assets/icons/bell.svg'),
                //     Positioned(
                //       left: 4,
                //       top: 0,
                //       child: Container(
                //         alignment: Alignment.center,
                //         width: 14,
                //         height: 14,
                //         decoration: BoxDecoration(
                //           color: Color(0xFFE42168),
                //           shape: BoxShape.circle,
                //         ),
                //         child: Text(
                //           '5',
                //           style: FontPalette.hW400S8.copyWith(color: kWhite),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Widget _buildCircularButton({
//   required IconData icon,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: EdgeInsets.all(8.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Icon(icon, size: 20.sp, color: Colors.black87),
//     ),
//   );
// }
PreferredSizeWidget buildSeamlessAppBar(
  BuildContext context,
  Map<String, dynamic>? arguments, {
  bool? isLeading = false,
  String? title,
  double? height,
  bool? isNotification = false,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(height ?? 55.h),
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB7E8CA),
            Color(0xFFF2F2F2), // This should match your body's starting color
          ],
          stops: [0.0, 0.9], // Adjust gradient distribution
        ),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Make AppBar transparent
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                if (isLeading == true) ...[
                  Container(
                    padding: EdgeInsets.only(left: 5.w),
                    alignment: Alignment.center,
                    height: 39.h,
                    width: 39.w,
                    decoration: const BoxDecoration(
                      color: kWhite,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                    ),
                  ),
                  SizedBox(width: 10.w),
                ],
                Expanded(
                  child: Text(
                    title ?? '',
                    style: FontPalette.hW400S18,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isNotification == false)
                  GestureDetector(
                    onTap: () {
                      context.push(routeNotification);
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SvgPicture.asset('assets/icons/bell.svg'),
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            alignment: Alignment.center,
                            width: 14.w,
                            height: 14.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE42168),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '5',
                              style: FontPalette.hW400S8.copyWith(
                                color: kWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
