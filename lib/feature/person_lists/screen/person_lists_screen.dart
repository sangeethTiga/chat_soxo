import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/group/screen/widgets/build_item_widget.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
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
        child: BlocBuilder<PersonListsCubit, PersonListsState>(
          builder: (context, state) {
            return Column(
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
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.personList?.length,
                              itemBuilder: (context, i) {
                                final data = state.personList?[i];

                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();

                                    context.read<ChatCubit>().getChatEntry(
                                      chatId: data?.id,
                                      userId: 2,
                                    );

                                    context.read<ChatCubit>().initStateClear();

                                    context.push(
                                      routeChatDetail,
                                      extra: {
                                        "title": data?.name,
                                        "chatId": data?.id,
                                      },
                                    );
                                  },
                                  child: buildChatContacts(
                                    data?.name ?? '',
                                    () {
                                      HapticFeedback.selectionClick();

                                      context.read<ChatCubit>().getChatEntry(
                                        chatId: data?.id,
                                        userId: 2,
                                      );

                                      context
                                          .read<ChatCubit>()
                                          .initStateClear();

                                      context.push(
                                        routeChatDetail,
                                        extra: {
                                          "title": data?.name,
                                          "chatId": data?.id,
                                        },
                                      );
                                    },

                                    isShow: true,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
