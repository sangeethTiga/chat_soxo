import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/group/screen/widgets/build_item_widget.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/chat_request/chat_request.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class GroupScreen extends StatelessWidget {
  final Map<String, dynamic>? data;

   GroupScreen({super.key, this.data});

  final TextEditingController textEditingController =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: data?['title'] ?? 'Group',
        context,
        {},
        isLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF2F2F2), Color(0xFFB7E8CA)],
                ),
              ),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: MainPadding(
                  top: 18.h,
                  child: BlocBuilder<PersonListsCubit, PersonListsState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(top: 5.h),
                                  height: 48.h,
                                  width: 48.w,
                                  decoration: BoxDecoration(
                                    color: Color(0XFFDEDEDE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(13.0),
                                    child: SvgPicture.asset(
                                      'assets/icons/Group 1000006903.svg',
                                    ),
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              Expanded(
                                flex: 4,
                                child: TextFeildWidget(
                                  controller: textEditingController,
                                  hight: 48.h,
                                  fillColor: kWhite,
                                  hintText:
                                      'Enter ${data?['subtitle'] ?? 'Group'} Name',
                                  inputBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    borderSide: BorderSide(
                                      color: Color(0xffCACACA),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                flex: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 2.h),
                                  child: InkWell(
                                    onTap: () {
                                      context.read<PersonListsCubit>().createChat(ChatRequest(
                                        mode: 'MIS',
                                        type: 'group',
                                        code: 'TEST',
                                        title: textEditingController.text,
                                        description: 'Test',
                                        status: 'Running',
                                        createdBy: 1,
                                        branchPtr: 'TR',
                                         userChats: state.selectedUsers
                                      ));
                                    },
                                    child: Container(
                                      height: 47.h,
                                      width: 48.w,
                                      decoration: BoxDecoration(
                                        color: Color(0XFF3D9970),
                                        borderRadius: BorderRadius.circular(
                                          13.r,
                                        ),
                                      ),
                                      child: Icon(Icons.check, color: kWhite),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 3.w),
                                child: Text(
                                  'Select Members',
                                  style: FontPalette.hW400S12.copyWith(
                                    color: Color(0XFFADB5BD),
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              SizedBox(
                                width: 245.w,
                                child: Divider(color: Color(0XFFEEEEEE)),
                              ),
                            ],
                          ),
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
                          14.verticalSpace,
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.personList?.length,
                              itemBuilder: (context, i) {
                                final data = state.personList?[i];
                                final isSelected = state.isUserSelected(
                                  data?.id ?? 0,
                                );

                                return buildChatContacts(
                                  data?.name ?? '',
                                  () {
                                    context
                                        .read<PersonListsCubit>()
                                        .toggleUserSelection(data!);
                                  },
                                  isShow: false,
                                  isSelected: isSelected,
                                );
                              },
                            ),
                          ),
                          // Expanded(

                          // child: ListView(
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: 0,
                          //     vertical: 0,
                          //   ),
                          //   children: [
                          //     buildChatContacts(
                          //       'SA',
                          //       Colors.blue,
                          //       'Sam',
                          //       'Pls Review',
                          //       'Today',
                          //       1,
                          //     ),
                          //     buildChatContacts(
                          //       'AT',
                          //       Colors.green,
                          //       'Anoop Ts',
                          //       'How is it going?',
                          //       '17/5',
                          //       0,
                          //     ),
                          //   ],
                          // ),
                          // ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
