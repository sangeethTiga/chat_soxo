import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chat',
                    style: FontPalette.hW400S18.copyWith(color: kBlack),
                  ),
                  Stack(
                    children: [
                      SvgPicture.asset('assets/icons/bell.svg'),
                      Positioned(
                        left: 4,
                        top: 0,
                        child: Container(
                          alignment: Alignment.center,
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(0xFFE42168),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '5',
                            style: FontPalette.hW400S8.copyWith(color: kWhite),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: MainPadding(
                top: 18.h,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: Row(
                        children: [
                          Row(
                            children: [
                              _buildTab('All', true, width: 20.w),
                              6.horizontalSpace,
                              _buildTab('Group Chat', false, width: 10.w),
                              6.horizontalSpace,
                              _buildTab('Personal Chat', false, width: 10.w),
                              6.horizontalSpace,
                              _buildTab('Broadcast', false, width: 10.w),
                            ],
                          ),
                        ],
                      ),
                    ),
                    12.verticalSpace,
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        children: [
                          _buildChatItem(
                            'RD',
                            Colors.blue,
                            'Internal Review',
                            'Pls Review',
                            'Today',
                            1,
                          ),
                          _buildChatItem(
                            'AT',
                            Colors.green,
                            'Anoop Ts',
                            'How is it going?',
                            '17/5',
                            0,
                          ),
                          _buildChatItem(
                            'CS',
                            Colors.deepOrange,
                            'Case Study\'s',
                            'Please check xary image',
                            'Today',
                            1,
                          ),
                          _buildChatItem(
                            'RD',
                            Colors.blue,
                            'Internal Review',
                            'Pls Review',
                            'Today',
                            1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {},
        backgroundColor: Color(0XFF3D9970),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset('assets/icons/Group 1000007039.svg'),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected, {double? width}) {
    return Container(
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: width ?? 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isSelected ? kPrimaryColor : Color(0XFFE3E3E3),
        ),
      ),
      child: Text(
        text,
        style: FontPalette.hW500S12.copyWith(color: Color(0XFF0F1828)),
      ),
    );
  }

  Widget _buildChatItem(
    String initials,
    Color avatarColor,
    String name,
    String message,
    String time,
    int unreadCount,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.only(left: 6.w, right: 8.w, bottom: 6.h, top: 6.h),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
            ),
            child: Center(
              child: Text(
                initials,
                style: FontPalette.hW700S14.copyWith(color: kWhite),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: FontPalette.hW600S14),
                SizedBox(height: 4),
                Text(
                  message,
                  style: FontPalette.hW400S12.copyWith(
                    color: Color(0XFFADB5BD),
                  ),
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
                time,
                style: TextStyle(color: Color(0XFFA4A4A4), fontSize: 12),
              ),
              if (unreadCount > 0) ...[
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
}
