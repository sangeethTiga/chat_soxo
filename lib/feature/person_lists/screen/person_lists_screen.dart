import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart'
    hide UserChat;
import 'package:soxo_chat/feature/group/screen/widgets/build_item_widget.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/chat_request/chat_request.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/appbar/appbar.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_card.dart';
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
        child: BlocConsumer<PersonListsCubit, PersonListsState>(
          listener: (context, state) {
            if (state.isCreate == ApiFetchStatus.success) {
              context.read<ChatCubit>().getChatList();
            }
          },
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

                                return BlocSelector<
                                  ChatCubit,
                                  ChatState,
                                  List<ChatListResponse>
                                >(
                                  selector: (state) {
                                    return state.chatList ?? [];
                                  },
                                  builder: (context, state) {
                                    return buildChatContacts(
                                      data?.name ?? '',
                                      () async {
                                        final user = await AuthUtils.instance
                                            .readUserData();
                                        final myUserId = int.tryParse(
                                          user?.result?.userId.toString() ?? '',
                                        );

                                        bool chatExists = false;
                                        int? existingChatId;

                                        for (ChatListResponse element
                                            in state) {
                                          // Check if this chat has exactly these two members
                                          final participantIds =
                                              element.userChats
                                                  ?.map((u) => u.userId)
                                                  .toList() ??
                                              [];

                                          if (participantIds.contains(
                                                data?.userId,
                                              ) &&
                                              participantIds.contains(
                                                myUserId,
                                              )) {
                                            chatExists = true;
                                            existingChatId = element.chatId;
                                            break;
                                          }
                                        }

                                        if (chatExists) {
                                          // Open existing chat
                                          await context
                                              .read<ChatCubit>()
                                              .getChatEntry(
                                                chatId: existingChatId!,
                                              );
                                          context.push(
                                            routeChatDetail,
                                            extra: {
                                              "title": data?.name,
                                              "chat_id": existingChatId,
                                            },
                                          );
                                        } else {
                                          final chatResponse = await context
                                              .read<PersonListsCubit>()
                                              .createChat(
                                                ChatRequest(
                                                  mode: 'MIS',
                                                  type: 'personal',
                                                  code: generateRandomString(4),
                                                  title: '',
                                                  description: '',
                                                  status: 'Running',
                                                  createdBy: 1,
                                                  branchPtr: 'TR',
                                                  firmPtr: "F1",
                                                  userChats: [
                                                    UserChat(
                                                      userId: data?.id,
                                                      role: 'member',
                                                      type: 'Normal',
                                                    ),
                                                    UserChat(
                                                      userId: myUserId,
                                                      role: 'member',
                                                      type: 'Normal',
                                                    ),
                                                  ],
                                                ),
                                              );

                                          if (chatResponse?.chatId != null) {
                                            context.push(
                                              routeChatDetail,
                                              extra: {
                                                "title": data?.name,
                                                "chat_id":
                                                    chatResponse!.chatId ?? 0,
                                              },
                                            );
                                          }
                                        }
                                      },

                                      isShow: true,
                                    );
                                  },
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
