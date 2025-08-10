import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_bubble_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/file_picker_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/record_dialog.dart';
import 'package:soxo_chat/shared/animation/empty_chat.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/app/list/helper.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/alert/alert_dialog_custom.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_category.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class SingleChatScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const SingleChatScreen({super.key, this.data});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowRotationAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    context.read<ChatCubit>().resetChatState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _arrowRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleViewToggle() {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.arrowSelected();

    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithProfile(context, {}, title: widget.data?['title']),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: _handleErrorMessage,
        child: _buildBody(),
      ),
    );
  }

  void _handleErrorMessage(BuildContext context, ChatState state) {
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
  }

  Widget _buildBody() {
    return Container(
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
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: ChatContent(
                      key: const ValueKey('chat'),
                      data: widget.data,
                      onToggleTap: _handleViewToggle,
                      arrowAnimation: _arrowRotationAnimation,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatContent extends StatelessWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onToggleTap;
  final Animation<double> arrowAnimation;

  const ChatContent({
    super.key,
    this.data,
    required this.onToggleTap,
    required this.arrowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ChatCubit, ChatState, List<Entry>>(
      selector: (state) {
        return state.chatEntry?.entries ?? [];
      },
      builder: (context, state) {
        return Column(
          children: [
            const Expanded(child: OptimizedChatMessagesList()),
            MessageInputSection(chatData: data),
          ],
        );
      },
    );
  }
}

class OptimizedChatMessagesList extends StatefulWidget {
  const OptimizedChatMessagesList({super.key});

  @override
  State<OptimizedChatMessagesList> createState() =>
      _OptimizedChatMessagesListState();
}

class _OptimizedChatMessagesListState extends State<OptimizedChatMessagesList> {
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

  void _scrollToBottom() {
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
          return _buildShimmerList();
        }

        if (data.entries?.isEmpty ?? true) {
          return const AnimatedEmptyChatWidget();
        }

        return _buildMessagesList(data.entries!);
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 3,
      itemBuilder: (context, index) =>
          ChatMessageShimmer(isSent: index % 2 == 0),
    );
  }

  Widget _buildMessagesList(List<Entry> entries) {
    final pinnedList = entries
        .where(
          (e) =>
              (e.pinned ?? '').trim().toUpperCase() == 'Y' ||
              (e.messageType == 'html'),
        )
        .toList();
    return FutureBuilder(
      future: AuthUtils.instance.readUserData(),
      builder: (context, asyncSnapshot) {
        return ListView.builder(
          cacheExtent: 2000,

          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: pinnedList.length,
          itemBuilder: (context, index) {
            final messageData = pinnedList[index];
            if (index == pinnedList.length - 1) {
              _scrollToBottom();
            }
            final int userId =
                int.tryParse(
                  asyncSnapshot.data?.result?.userId.toString() ?? '0',
                ) ??
                0;
            return Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: ChatBubbleMessage(
                type: messageData.messageType,
                message: messageData.content ?? '',
                timestamp: getFormattedDate(messageData.createdAt ?? ''),
                isSent: messageData.senderId == userId ? true : false,
                chatMedias: messageData.chatMedias,
              ),
            );
          },
        );
      },
    );
  }
}

class UnifiedMessageInput extends StatefulWidget {
  final Map<String, dynamic>? chatData;
  final bool isGroup;

  const UnifiedMessageInput({super.key, this.chatData, this.isGroup = false});

  @override
  State<UnifiedMessageInput> createState() => _UnifiedMessageInputState();
}

class _UnifiedMessageInputState extends State<UnifiedMessageInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _recordingAnimationController;
  late Animation<double> _pulseAnimation;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
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
      setState(() => _hasText = hasText);
    }
  }

  void _startRecording() {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.startRecording();
    _recordingAnimationController.repeat(reverse: true);

    showRecordingDialog(
      context,
      _pulseAnimation,
      _cancelRecording,
      _stopRecording,
    );
  }

  void _stopRecording() async {
    final user = await AuthUtils.instance.readUserData();
    if (!widget.isGroup) {
      context.read<ChatCubit>().stopRecordingAndSend(
        AddChatEntryRequest(
          chatId: widget.chatData?['chat_id'],
          senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
          type: 'N',
          typeValue: 0,
          messageType: 'voice',
          content: 'Voice message',
          source: 'Mobile',
        ),
      );
    }

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
    final user = await AuthUtils.instance.readUserData();

    if (widget.isGroup) {
      _handleGroupMessage(messageText);
      return;
    }

    final selectedFiles = context.read<ChatCubit>().state.selectedFiles ?? [];
    if (messageText.isEmpty && selectedFiles.isEmpty) return;

    _messageController.clear();

    await context.read<ChatCubit>().createChat(
      AddChatEntryRequest(
        chatId: widget.chatData?['chat_id'],
        senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
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

  void _handleGroupMessage(String messageText) {
    if (messageText.isEmpty) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();
    log('Group message sent: $messageText');
  }

  @override
  Widget build(BuildContext context) {
    return MainPadding(
      right: 16,
      bottom: widget.isGroup ? 0.h : 28.h,
      child: Row(
        children: [
          SizedBox(width: 10.w),
          if (!widget.isGroup)
            _buildFilePickerButton(context.watch<ChatCubit>().state),
          SizedBox(width: 10.w),
          Expanded(child: _buildTextInput()),
          SizedBox(width: 6.w),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildFilePickerButton(ChatState state) {
    return InkWell(
      onTap: () => showFilePickerBottomSheet(context),
      child: (state.selectedFiles?.isNotEmpty ?? false)
          ? Badge.count(
              backgroundColor: kPrimaryColor,
              count: state.selectedFiles?.length ?? 0,
              child: SvgPicture.asset('assets/icons/Vector.svg'),
            )
          : SvgPicture.asset('assets/icons/Vector.svg'),
    );
  }

  Widget _buildTextInput() {
    return TextFeildWidget(
      hintText: 'Type a message',
      controller: _messageController,
      inputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xffCACACA), width: 1),
      ),
      suffixIcon: _buildVoiceButton(),

      maxLines: 1,
    );
  }

  Widget _buildVoiceButton() {
    return BlocSelector<ChatCubit, ChatState, bool>(
      selector: (state) => state.hasRecordingPermission,
      builder: (context, hasPermission) {
        return InkWell(
          onTap: hasPermission
              ? _startRecording
              : () => showPermissionDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset('assets/icons/Group 1000006770.svg'),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return AnimatedOpacity(
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
    );
  }
}

class MessageInputSection extends StatelessWidget {
  final Map<String, dynamic>? chatData;

  const MessageInputSection({super.key, this.chatData});

  @override
  Widget build(BuildContext context) {
    return UnifiedMessageInput(chatData: chatData);
  }
}
