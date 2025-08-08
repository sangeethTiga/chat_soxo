import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/screen/single_chat_screen.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_bubble_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/file_picker_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/record_dialog.dart';
import 'package:soxo_chat/shared/animation/empty_chat.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/alert/alert_dialog_custom.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_category.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const ChatDetailScreen({super.key, this.data});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _recordingAnimationController;
  late Animation<double> _arrowRotationAnimation;

  late TextEditingController _messageController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late ScrollController _scrollController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _messageController.addListener(_onTextChanged);

    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentAnimationController.forward();
    });
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _initializeAnimations() {
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _arrowRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _recordingAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    _contentAnimationController.dispose();
    _recordingAnimationController.dispose();
    _scrollController.dispose();
    _messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _handleArrowTap() {
    context.read<ChatCubit>().arrowSelected();
    if (_arrowAnimationController.isCompleted) {
      _arrowAnimationController.reverse();
    } else {
      _arrowAnimationController.forward();
    }

    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  void _startRecording(BuildContext context) {
    context.read<ChatCubit>().startRecording();
    _recordingAnimationController.repeat(reverse: true);
    showRecordingDialog(
      context,
      _pulseAnimation,
      _cancelRecording,
      _stopRecording,
    );
  }

  void _stopRecording() {
    context.read<ChatCubit>().stopRecordingAndSend();
    _recordingAnimationController.stop();
    Navigator.pop(context);
  }

  void _cancelRecording() {
    context.read<ChatCubit>().cancelRecording();
    _recordingAnimationController.stop();
    Navigator.pop(context);
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    final hasFiles =
        context.read<ChatCubit>().state.selectedFiles?.isNotEmpty ?? false;
    final selectedFiles = context.read<ChatCubit>().state.selectedFiles ?? [];
    log(
      'Screen: Selected files count: ${selectedFiles.length}',
    ); // Add this log

    if (messageText.isEmpty && !hasFiles) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    await context.read<ChatCubit>().createChat(
      AddChatEntryRequest(
        chatId: widget.data?['chat_id'],
        senderId: 45,
        type: 'N',
        typeValue: 0,
        messageType: 'text',
        content: messageText.isNotEmpty ? messageText : 'File attachment',
        source: 'Website',
        attachedFiles: selectedFiles,
      ),
      files: selectedFiles,
    );

    log('Message sent: $messageText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithProfile(context, {}, title: widget.data?['title']),

      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<ChatCubit>().clearError();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
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
                    child: AnimatedSwitcher(
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: (state.isArrow) == false
                          ? _buildChatContent(key: const ValueKey('chat'))
                          : _buildGroupContent(
                              key: const ValueKey('group'),
                              state: state,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatContent({required Key key}) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Column(
          key: key,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    context.push(
                      routeSingleChat,
                      extra: {"title": widget.data?['title'], 'chat_id': '2'},
                    );
                  },
                  child: MainPadding(
                    top: 16.h,
                    bottom: 0,
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/icons/mynaui_pin-solid.svg'),
                        5.horizontalSpace,
                        Image.asset('assets/images/Rectangle 1.png'),
                        5.horizontalSpace,
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'Anoop TS  ',
                              style: FontPalette.hW700S14.copyWith(
                                color: const Color(0XFF515978),
                              ),
                              children: [
                                TextSpan(
                                  text: 'send request to case',
                                  style: FontPalette.hW500S14.copyWith(
                                    color: const Color(0XFF515978),
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SvgPicture.asset('assets/icons/clock.svg'),
                        5.horizontalSpace,
                        const Text('45 min'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 34.w, top: 0.h),
                  child: Row(
                    children: [
                      Text(
                        '3 Replayed , 4 Pending',
                        style: FontPalette.hW500S12.copyWith(
                          color: const Color(0XFF166FF6),
                        ),
                      ),
                      5.horizontalSpace,
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SvgPicture.asset('assets/icons/Eye.svg'),
                      ),
                    ],
                  ),
                ),
                AnimatedDividerCard(
                  onArrowTap: _handleArrowTap,
                  arrowAnimation: _arrowRotationAnimation,
                ),
              ],
            ),

            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isChatEntry == ApiFetchStatus.loading) {
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ChatMessageShimmer(isSent: index % 2 == 0);
                      },
                    );
                  }
                  if (state.chatEntry?.entries?.isEmpty ?? true) {
                    return const AnimatedEmptyChatWidget();
                  }

                  return ListView.builder(
                    controller: _scrollController,

                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: state.chatEntry?.entries?.length,
                    itemBuilder: (context, index) {
                      final data = state.chatEntry?.entries?[index];

                      if (index ==
                          (state.chatEntry?.entries?.length ?? 0) - 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }

                      if (state.chatEntry?.entries?.isNotEmpty ?? false) {
                        return Column(
                          children: [
                            SizedBox(height: 15.h),
                            ChatBubbleMessage(
                              type: data?.messageType,
                              message: data?.content ?? '',
                              timestamp: '12-2-2025 ,15:24',
                              isSent: true,
                            ),
                          ],
                        );
                      } else {
                        final message = data;
                      }
                      return null;
                    },
                  );
                },
              ),
            ),

            MainPadding(
              right: 16,
              bottom: 28.h,
              child: Row(
                children: [
                  10.horizontalSpace,

                  InkWell(
                    onTap: () {
                      showFilePickerBottomSheet(context);
                    },

                    child: SvgPicture.asset('assets/icons/Vector.svg'),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: TextFeildWidget(
                      hintText: 'Type a message',
                      controller: _messageController,
                      inputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Color(0xffCACACA),
                          width: 1,
                        ),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          if (state.hasRecordingPermission) {
                            _startRecording(context);
                          } else {
                            showPermissionDialog(context);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/Group 1000006770.svg',
                          ),
                        ),
                      ),
                    ),
                  ),
                  6.horizontalSpace,
                  AnimatedOpacity(
                    opacity: _hasText ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 200),
                    child: _hasText
                        ? Padding(
                            padding: EdgeInsets.only(top: 5.h),
                            child: GestureDetector(
                              onTap: _sendMessage,
                              child: Container(
                                padding: EdgeInsets.only(left: 4.w),
                                alignment: Alignment.center,
                                height: 48.h,
                                width: 48.w,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.send, color: Colors.white),
                              ),
                            ),
                          )
                        : SizedBox.fromSize(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupContent({required Key key, required ChatState state}) {
    return Column(
      key: key,
      children: [
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 100)),
              curve: Curves.easeOutBack,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _contentAnimationController,
                        curve: Interval(
                          index * 0.2,
                          0.6 + (index * 0.2),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _contentAnimationController,
                      curve: Interval(
                        index * 0.1,
                        0.5 + (index * 0.1),
                        curve: Curves.easeIn,
                      ),
                    ),
                  ),
                  child: const GroupCardWidget(),
                ),
              ),
            );
          },
          separatorBuilder: (context, i) {
            return const Divider(color: Color(0XFFE3E3E3), thickness: 0);
          },
          itemCount: 3,
        ),
        AnimatedDividerCard(
          onArrowTap: _handleArrowTap,
          arrowAnimation: _arrowRotationAnimation,
        ),
        const Spacer(),

        MainPadding(
          right: 16,
          bottom: 0.h,
          child: Row(
            children: [
              10.horizontalSpace,

              SvgPicture.asset('assets/icons/Vector.svg'),
              10.horizontalSpace,
              Expanded(
                child: TextFeildWidget(
                  hintText: 'Type a message',
                  controller: _messageController,
                  inputBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Color(0xffCACACA), width: 1),
                  ),
                  suffixIcon: InkWell(
                    onTap: () {
                      if (state.hasRecordingPermission) {
                        _startRecording(context);
                      } else {
                        showPermissionDialog(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        'assets/icons/Group 1000006770.svg',
                      ),
                    ),
                  ),
                ),
              ),
              6.horizontalSpace,
              AnimatedOpacity(
                opacity: _hasText ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: _hasText
                    ? Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: EdgeInsets.only(left: 4.w),
                            alignment: Alignment.center,
                            height: 48.h,
                            width: 48.w,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      )
                    : SizedBox.fromSize(),
              ),
            ],
          ),
        ),
        28.verticalSpace,
      ],
    );
  }
}
