import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_chat_item.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/build_tab.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/flating_button.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});
  final _key = GlobalKey<ExpandableFabState>();

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
                              buildTab('All', true, width: 20.w),
                              6.horizontalSpace,
                              buildTab('Group Chat', false, width: 10.w),
                              6.horizontalSpace,
                              buildTab('Personal Chat', false, width: 10.w),
                              6.horizontalSpace,
                              buildTab('Broadcast', false, width: 10.w),
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
                          buildChatItem(
                            'RD',
                            Colors.blue,
                            'Internal Review',
                            'Pls Review',
                            'Today',
                            1,
                          ),
                          buildChatItem(
                            'AT',
                            Colors.green,
                            'Anoop Ts',
                            'How is it going?',
                            '17/5',
                            0,
                          ),
                          buildChatItem(
                            'CS',
                            Colors.deepOrange,
                            'Case Study\'s',
                            'Please check xary image',
                            'Today',
                            1,
                          ),
                          buildChatItem(
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
      floatingActionButtonLocation: ExpandableFab.location,

      floatingActionButton: FlatingWidget(keys: _key),
    );
  }
}
