import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/user_data.dart';
import 'package:soxo_chat/shared/app/list/helper.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/animated_divider/notification_anmation.dart';

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
                  10.horizontalSpace,
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
                  fontSize: notificationCount > 99 ? 6 : 8,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

// PreferredSizeWidget buildAppBarWithProfile(
//   BuildContext context,
//   Map<String, dynamic>? arguments, {
//   final String? title,
// }) {
//   return PreferredSize(
//     preferredSize: Size.fromHeight(65.h),
//     child: AppBar(
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.only(left: 5.w),
//                   alignment: Alignment.center,
//                   height: 39.h,
//                   width: 39.w,
//                   decoration: const BoxDecoration(
//                     color: kWhite,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.arrow_back_ios),
//                   ),
//                 ),
//                 6.horizontalSpace,
//                 ChatAvatar(name: title ?? '', size: 40.h),
//                 6.horizontalSpace,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     4.verticalSpace,
//                     Text(title ?? '', style: FontPalette.hW400S18),
//                     1.verticalSpace,

//                     Row(
//                       children: [
//                         Container(
//                           height: 8.h,
//                           width: 8.w,
//                           decoration: const BoxDecoration(
//                             color: Color(0xFF68D391),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         5.horizontalSpace,
//                         Text('Online', style: FontPalette.hW600S12),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
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
          colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
          stops: [0.0, 0.9],
        ),
      ),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                  AnimatedNotificationBell(
                    notificationCount: 5,
                    onTap: () {
                      context.push(routeNotification);
                    },
                    autoAnimate: true,
                    animationInterval: const Duration(seconds: 3),
                  ),
                // GestureDetector(
                //   onTap: () {
                //     context.push(routeNotification);
                //   },
                //   child: Stack(
                //     clipBehavior: Clip.none,
                //     children: [
                //       SvgPicture.asset('assets/icons/bell.svg'),
                //       Positioned(
                //         right: -2,
                //         top: -2,
                //         child: Container(
                //           alignment: Alignment.center,
                //           width: 14.w,
                //           height: 14.h,
                //           decoration: const BoxDecoration(
                //             color: Color(0xFFE42168),
                //             shape: BoxShape.circle,
                //           ),
                //           child: Text(
                //             '5',
                //             style: FontPalette.hW400S8.copyWith(
                //               color: kWhite,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                18.horizontalSpace,
              ],
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTapDown: (details) {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  details.globalPosition.dx, // left
                  details.globalPosition.dy, // top
                  0, // right
                  0, // bottom
                ),
                items: [
                  const PopupMenuItem(value: 'Logout', child: Text('Logout')),
                ],
              ).then((value) {
                if (value == 'Logout') {
                  Helper().logout(context);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6, right: 8),
              child: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    ),
  );
}

PreferredSizeWidget buildAppBarWithProfile(
  BuildContext context,
  Map<String, dynamic>? arguments, {
  final String? title,
  final String? image,
  final Function? onTap,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(65.h),
    child: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: InkWell(
        onTap: () {
          onTap!();
        },
        child: Container(
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
                  // Back button
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

                  // Chat avatar
                  CachedChatAvatar(
                    name: title ?? '',
                    size: 40.h,
                    imageUrl: image,
                  ),
                  6.horizontalSpace,

                  // Chat info section with improved participant display
                  Expanded(
                    child: BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        final userChats = state.chatEntry?.userChats ?? [];
                        log("WHAT IS ${userChats.length}");
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Chat title
                            Text(
                              title ?? '',
                              style: FontPalette.hW400S18,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            2.verticalSpace,

                            // Participants and status
                            Row(
                              children: [
                                userChats.length > 2
                                    ? Expanded(
                                        child: userChats.isNotEmpty
                                            ? _buildParticipantsWithCount(
                                                userChats,
                                              )
                                            : Text(
                                                'No participants',
                                                style: FontPalette.hW600S12
                                                    .copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                              ),
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            height: 8.h,
                                            width: 8.w,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF68D391),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          4.horizontalSpace,
                                          Text(
                                            'Online',
                                            style: FontPalette.hW600S12,
                                          ),
                                        ],
                                      ),

                                // Online status indicator
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // // Menu button
                  // PopupMenuButton<String>(
                  //   icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  //   onSelected: (value) {
                  //     switch (value) {
                  //       case 'view_profile':
                  //         // Handle view profile
                  //         break;
                  //       case 'clear_chat':
                  //         // Handle clear chat
                  //         break;
                  //       case 'block':
                  //         // Handle block user
                  //         break;
                  //     }
                  //   },
                  //   itemBuilder: (context) => [
                  //     PopupMenuItem(
                  //       value: 'view_profile',
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.person, size: 20),
                  //           8.horizontalSpace,
                  //           Text('View Profile'),
                  //         ],
                  //       ),
                  //     ),
                  //     PopupMenuItem(
                  //       value: 'clear_chat',
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.clear_all, size: 20),
                  //           8.horizontalSpace,
                  //           Text('Clear Chat'),
                  //         ],
                  //       ),
                  //     ),
                  //     PopupMenuItem(
                  //       value: 'block',
                  //       child: Row(
                  //         children: [
                  //           Icon(Icons.block, size: 20, color: Colors.red),
                  //           8.horizontalSpace,
                  //           Text('Block', style: TextStyle(color: Colors.red)),
                  //         ],
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
    ),
  );
}

Widget _buildParticipantsWithCount(List<dynamic> userChats) {
  if (userChats.isEmpty) {
    return Text(
      'No participants',
      style: FontPalette.hW600S12.copyWith(color: Colors.grey[600]),
    );
  }

  List participantNames = userChats
      .map((chat) => chat?.user?.name?.trim() ?? '')
      .where((name) => name.isNotEmpty)
      .toSet() // Remove duplicates
      .toList();

  String displayText;

  if (participantNames.length == 1) {
    // Individual chat - show "Online" instead of name
    displayText = 'Online';
  } else if (participantNames.length == 2) {
    // Two people - show both names
    displayText = participantNames.join(' and ');
  } else if (participantNames.length == 3) {
    // Three people - show all names
    displayText =
        '${participantNames[0]}, ${participantNames[1]} and ${participantNames[2]}';
  } else {
    // More than 3 - show first 2 names and count
    displayText =
        '${participantNames[0]}, ${participantNames[1]} and ${participantNames.length - 2} others';
  }

  return Text(
    displayText,
    style: FontPalette.hW600S12.copyWith(color: Colors.grey[600]),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}

// Simplified version that works with your current data structure
PreferredSizeWidget buildAppBarWithProfileSimple(
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
                // Back button
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

                // Chat avatar
                ChatAvatar(name: title ?? '', size: 40.h),
                6.horizontalSpace,

                // Chat info section - Simplified
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final userChats = state.chatEntry?.userChats ?? [];
                      final isGroupChat = userChats.length > 2;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Chat title
                          Text(
                            title ?? '',
                            style: FontPalette.hW400S18,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          2.verticalSpace,

                          // Status information
                          Row(
                            children: [
                              // Online status indicator
                              Container(
                                height: 8.h,
                                width: 8.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF68D391),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              4.horizontalSpace,

                              // Status text - Simplified
                              Expanded(
                                child: Text(
                                  isGroupChat
                                      ? '${userChats.length} participants'
                                      : 'Online',
                                  style: FontPalette.hW600S12.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Menu button
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                  onSelected: (value) {
                    switch (value) {
                      case 'view_profile':
                        // Handle view profile
                        break;
                      case 'clear_chat':
                        // Handle clear chat
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view_profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 20),
                          8.horizontalSpace,
                          Text('View Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear_chat',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all, size: 20),
                          8.horizontalSpace,
                          Text('Clear Chat'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Helper methods for advanced version
int _getOnlineUserCount(List<dynamic>? userChats) {
  if (userChats == null) return 0;
  // Since isOnline property doesn't exist, return a default count
  // You can modify this based on your actual online status logic
  return 1; // Assume at least one user is online, or implement your own logic
}

Color _getStatusColor(int onlineCount) {
  return onlineCount > 0 ? Color(0xFF68D391) : Colors.grey;
}

String _getStatusText(bool isGroupChat, int onlineCount, int totalUsers) {
  if (isGroupChat) {
    // For group chats, just show participant count since we don't have online status
    return '$totalUsers participants';
  } else {
    // For individual chats, show a generic online status
    return 'Online'; // You can change this to 'Last seen recently' or implement actual status
  }
}
