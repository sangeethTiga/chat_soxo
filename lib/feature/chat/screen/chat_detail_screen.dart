import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
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
  late Animation<double> _arrowRotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentAnimationController.forward();
    });
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

    _arrowRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    _contentAnimationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithProfile(context, {}, title: widget.data?['title']),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () => context.read<ChatCubit>().clearError(),
                ),
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
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
                  child: BlocSelector<ChatCubit, ChatState, bool>(
                    selector: (state) => state.isArrow,
                    builder: (context, isArrow) {
                      return AnimatedSwitcher(
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
                        child: !isArrow
                            ? ChatContent(
                                key: const ValueKey('chat'),
                                data: widget.data,
                                onArrowTap: _handleArrowTap,
                                arrowAnimation: _arrowRotationAnimation,
                              )
                            : GroupContent(
                                key: const ValueKey('group'),
                                onArrowTap: _handleArrowTap,
                                arrowAnimation: _arrowRotationAnimation,
                                contentAnimationController:
                                    _contentAnimationController,
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatContent extends StatefulWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onArrowTap;
  final Animation<double> arrowAnimation;

  const ChatContent({
    super.key,
    this.data,
    required this.onArrowTap,
    required this.arrowAnimation,
  });

  @override
  State<ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChatHeader(data: widget.data),
        AnimatedDividerCard(
          onArrowTap: widget.onArrowTap,
          arrowAnimation: widget.arrowAnimation,
        ),
        Expanded(child: ChatMessagesList(scrollController: _scrollController)),
        MessageInputSection(chatData: widget.data),
      ],
    );
  }
}

class GroupContent extends StatelessWidget {
  final VoidCallback onArrowTap;
  final Animation<double> arrowAnimation;
  final AnimationController contentAnimationController;

  const GroupContent({
    super.key,
    required this.onArrowTap,
    required this.arrowAnimation,
    required this.contentAnimationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                        parent: contentAnimationController,
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
                      parent: contentAnimationController,
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
          onArrowTap: onArrowTap,
          arrowAnimation: arrowAnimation,
        ),
        const Spacer(),
        const GroupMessageInput(),
        28.verticalSpace,
      ],
    );
  }
}

class ChatHeader extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ChatHeader({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            context.push(
              routeSingleChat,
              extra: {"title": data?['title'], 'chat_id': '2'},
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
      ],
    );
  }
}

// Optimized chat messages list that only rebuilds when chat data changes
class ChatMessagesList extends StatelessWidget {
  final ScrollController scrollController;

  const ChatMessagesList({super.key, required this.scrollController});
  final bool _shouldAutoScroll = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_shouldAutoScroll) return;

      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ChatCubit,
      ChatState,
      ({ApiFetchStatus? status, List<Entry>? entries})
    >(
      selector: (state) =>
          (status: state.isChatEntry, entries: state.chatEntry?.entries),
      builder: (context, data) {
        if (data.status == ApiFetchStatus.loading) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 3,
            itemBuilder: (context, index) =>
                ChatMessageShimmer(isSent: index % 2 == 0),
          );
        }

        if (data.entries?.isEmpty ?? true) {
          return const AnimatedEmptyChatWidget();
        }

        final entries = data.entries!;

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final messageData = entries[index];
            log("Message type: ${messageData.messageType}");

            if (index == entries.length - 1) {
              _scrollToBottom();
            }

            return Column(
              children: [
                SizedBox(height: 15.h),
                ChatBubbleMessage(
                  type: messageData.messageType,
                  message: messageData.content ?? '',
                  timestamp: '12-2-2025 ,15:24',
                  isSent: true,
                  chatMedias: messageData.chatMedias,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Separate message input section to handle text changes without affecting chat list
class MessageInputSection extends StatefulWidget {
  final Map<String, dynamic>? chatData;

  const MessageInputSection({super.key, this.chatData});

  @override
  State<MessageInputSection> createState() => _MessageInputSectionState();
}

class _MessageInputSectionState extends State<MessageInputSection>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _recordingAnimationController;
  late Animation<double> _pulseAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
    _recordingAnimationController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
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
    context.read<ChatCubit>().stopRecordingAndSend(
      AddChatEntryRequest(
        chatId: widget.chatData?['chat_id'],
        senderId: 45,
        type: 'N',
        typeValue: 0,
        messageType: 'voice',
        content: 'Voice message',
        source: 'Mobile',
      ),
    );
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
    final selectedFiles = context.read<ChatCubit>().state.selectedFiles ?? [];
    final hasFiles = selectedFiles.isNotEmpty;

    if (messageText.isEmpty && !hasFiles) return;

    // Clear input immediately for better UX
    _messageController.clear();
    // FocusScope.of(context).unfocus();

    await context.read<ChatCubit>().createChat(
      AddChatEntryRequest(
        chatId: widget.chatData?['chat_id'],
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
    return MainPadding(
      right: 16,
      bottom: 28.h,
      child: Row(
        children: [
          10.horizontalSpace,
          InkWell(
            onTap: () => showFilePickerBottomSheet(context),
            child: SvgPicture.asset('assets/icons/Vector.svg'),
          ),
          10.horizontalSpace,
          Expanded(
            child: TextFeildWidget(
              hintText: 'Type a message',
              controller: _messageController,
              inputBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(
                  color: Color(0xffCACACA),
                  width: 1,
                ),
              ),
              suffixIcon: BlocSelector<ChatCubit, ChatState, bool>(
                selector: (state) => state.hasRecordingPermission,
                builder: (context, hasPermission) {
                  return InkWell(
                    onTap: () {
                      if (hasPermission) {
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
                  );
                },
              ),
            ),
          ),
          6.horizontalSpace,
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
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
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Separate group message input to avoid duplication
class GroupMessageInput extends StatefulWidget {
  const GroupMessageInput({super.key});

  @override
  State<GroupMessageInput> createState() => _GroupMessageInputState();
}

class _GroupMessageInputState extends State<GroupMessageInput>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _recordingAnimationController;
  late Animation<double> _pulseAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
    _recordingAnimationController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _startRecording(BuildContext context) {
    context.read<ChatCubit>().startRecording();
    _recordingAnimationController.repeat(reverse: true);
    showRecordingDialog(
      context,
      _pulseAnimation,
      () {
        context.read<ChatCubit>().cancelRecording();
        _recordingAnimationController.stop();
        Navigator.pop(context);
      },
      () {
        // Handle group recording send
        _recordingAnimationController.stop();
        Navigator.pop(context);
      },
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    // Handle group message send
    log('Group message sent: $messageText');
  }

  @override
  Widget build(BuildContext context) {
    return MainPadding(
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
                borderSide: const BorderSide(
                  color: Color(0xffCACACA),
                  width: 1,
                ),
              ),
              suffixIcon: BlocSelector<ChatCubit, ChatState, bool>(
                selector: (state) => state.hasRecordingPermission,
                builder: (context, hasPermission) {
                  return InkWell(
                    onTap: () {
                      if (hasPermission) {
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
                  );
                },
              ),
            ),
          ),
          6.horizontalSpace,
          AnimatedOpacity(
            opacity: _hasText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
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
                        decoration: const BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// Placeholder for missing widgets - replace with your actual implementations
class AnimatedDividerCard extends StatelessWidget {
  final VoidCallback onArrowTap;
  final Animation<double> arrowAnimation;

  const AnimatedDividerCard({
    super.key,
    required this.onArrowTap,
    required this.arrowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onArrowTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: arrowAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: arrowAnimation.value * 3.14159,
                  child: const Icon(Icons.keyboard_arrow_down),
                );
              },
            ),
            const Expanded(child: Divider()),
          ],
        ),
      ),
    );
  }
}

class GroupCardWidget extends StatelessWidget {
  const GroupCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text('Group Card Widget'),
    );
  }
}
