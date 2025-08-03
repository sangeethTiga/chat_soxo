import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/group/screen/widgets/build_item_widget.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class PersonListsScreen extends StatelessWidget {
  const PersonListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(title: 'Person', context, {}, isLeading: true),
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
            // Container(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
            //     ),
            //   ),
            //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            //   child: SafeArea(
            //     child: Row(
            //       children: [
            //         Container(
            //           padding: EdgeInsets.only(left: 5.w),
            //           alignment: Alignment.center,
            //           height: 39.h,
            //           width: 39.w,
            //           decoration: BoxDecoration(
            //             color: kWhite,
            //             shape: BoxShape.circle,
            //           ),
            //           child: Center(
            //             child: IconButton(
            //               padding: EdgeInsets.zero,
            //               onPressed: () {
            //                 Navigator.pop(context);
            //               },
            //               icon: Icon(Icons.arrow_back_ios),
            //             ),
            //           ),
            //         ),
            //         10.horizontalSpace,
            //         Text('Person', style: FontPalette.hW400S18),
            //         Spacer(),
            //         Stack(
            //           children: [
            //             SvgPicture.asset('assets/icons/bell.svg'),
            //             Positioned(
            //               left: 4,
            //               top: 0,
            //               child: Container(
            //                 alignment: Alignment.center,
            //                 width: 14,
            //                 height: 14,
            //                 decoration: BoxDecoration(
            //                   color: Color(0xFFE42168),
            //                   shape: BoxShape.circle,
            //                 ),
            //                 child: Text(
            //                   '5',
            //                   style: FontPalette.hW400S8.copyWith(color: kWhite),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            Expanded(
              child: Container(
                // transform: Matrix4.translationValues(0, -20, 0),
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
                      10.verticalSpace,
                      TextFeildWidget(
                        hintStyle: FontPalette.hW400S16.copyWith(
                          color: Color(0XFFBFBFBF),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: SvgPicture.asset(
                            'assets/icons/Group 1000006923.svg',
                          ),
                        ),
                        hight: 48.h,
                        fillColor: kWhite,

                        hintText: 'Search Members',
                        inputBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: Color(0xffCACACA),
                            width: 1,
                          ),
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
                            buildChatContacts(
                              'RD',
                              Colors.blue,
                              'Internal Review',
                              'Pls Review',
                              'Today',
                              1,
                              isShow: true,
                            ),
                            buildChatContacts(
                              'AT',
                              Colors.green,
                              'Anoop Ts',
                              'How is it going?',
                              '17/5',
                              0,
                              isShow: true,
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
      ),
    );
  }
}
