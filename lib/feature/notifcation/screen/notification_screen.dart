import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/divider/divider_widget.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart'
    show MainPadding;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Notification',
        context,
        {},
        isLeading: true,
        isNotification: true,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F2F2), Color(0xFFB7E8CA)],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: MainPadding(
                  top: 10.h,
                  child: Column(
                    children: [
                      12.verticalSpace,
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Today',
                                  style: FontPalette.hW500S16.copyWith(
                                    color: Color(0XFF515978),
                                  ),
                                ),
                                8.horizontalSpace,
                                SizedBox(width: 300.w, child: dividerWidget()),
                              ],
                            ),
                            15.verticalSpace,
                            NotificationCardWidget(),
                            15.verticalSpace,
                            NotificationCardWidget(),
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
      ),
    );
  }
}

class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              color: Color(0XFFEEF3F1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset('assets/icons/-.svg'),
            ),
          ),
          6.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reminder for your meetings',
                      style: FontPalette.hW500S14,
                    ),
                    Text(
                      '9 min ago',
                      style: FontPalette.hW400S12.copyWith(
                        color: Color(0XFF515978),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Learn more about managing account info and \nactivity',
                  style: FontPalette.hW400S12.copyWith(
                    color: Color(0XFF515978),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
