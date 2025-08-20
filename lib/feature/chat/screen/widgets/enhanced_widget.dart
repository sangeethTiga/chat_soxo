import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/file_picker_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/record_dialog.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/alert/alert_dialog_custom.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class EnhancedUnifiedMessageInput extends StatefulWidget {
  final Map<String, dynamic>? chatData;
  final bool isGroup;
  final VoidCallback? onCancelReply;

  const EnhancedUnifiedMessageInput({
    super.key,
    this.chatData,
    this.isGroup = false,
    this.onCancelReply,
  });

  @override
  State<EnhancedUnifiedMessageInput> createState() =>
      _EnhancedUnifiedMessageInputState();
}

class _EnhancedUnifiedMessageInputState
    extends State<EnhancedUnifiedMessageInput>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _recordingAnimationController;
  late AnimationController _replyBarController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _replyBarAnimation;
  late FocusNode _focusNode;

  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _messageController = TextEditingController();
    _messageController.addListener(_onTextChanged);
    _focusNode = FocusNode();

    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _replyBarController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _recordingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _replyBarAnimation = CurvedAnimation(
      parent: _replyBarController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _recordingAnimationController.dispose();
    _replyBarController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    final user = await AuthUtils.instance.readUserData();

    final chatCubit = context.read<ChatCubit>();
    final isReply = chatCubit.state.isReplying;
    final replyingTo = chatCubit.state.replyingTo;

    if (widget.isGroup) {
      _handleGroupMessage(messageText);
      return;
    }

    final selectedFiles = chatCubit.state.selectedFiles ?? [];
    if (messageText.isEmpty && selectedFiles.isEmpty) return;

    _messageController.clear();
    setState(() => _hasText = false);

    if ((isReply ?? false) && replyingTo != null) {
      final baseRequest = AddChatEntryRequest(
        chatId: widget.chatData?['chat_id'],
        senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
        type: 'CR',
        typeValue: 0,
        messageType: 'text',
        content: messageText,
        source: 'Mobile',
        attachedFiles: selectedFiles,
        pinned: chatCubit.state.isPinned,
      );

      await chatCubit.sendReplyMessage(
        replyMessage: messageText,
        originalMessage: replyingTo,
        baseRequest: baseRequest,
      );
    } else {
      final request = AddChatEntryRequest(
        chatId: widget.chatData?['chat_id'],
        senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
        type: 'N',
        typeValue: 0,
        messageType: 'text',
        content: messageText.isNotEmpty ? messageText : 'File attachment',
        source: 'Mobile',
        attachedFiles: selectedFiles,
        pinned: chatCubit.state.isPinned,
      );

      await chatCubit.createChat(request, files: selectedFiles);
    }

    log('Message sent: $messageText${isReply ?? false ? ' (reply)' : ''}');
  }

  void _handleGroupMessage(String messageText) {
    if (messageText.isEmpty) return;

    _messageController.clear();
    setState(() => _hasText = false);
    FocusScope.of(context).unfocus();
    widget.onCancelReply?.call();

    log('Group message sent: $messageText');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        return previous.isReplying != current.isReplying;
      },
      listener: (context, state) {
        if (state.isReplying ?? false) {
          _replyBarController.forward();
          Future.delayed(Duration(milliseconds: 300), () {
            _focusNode.requestFocus();
          });
        } else {
          _replyBarController.reverse();
        }
      },
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            children: [
              SizeTransition(
                sizeFactor: _replyBarAnimation,
                child: (state.isReplying ?? false) && state.replyingTo != null
                    ? _buildReplyPreview(state.replyingTo!)
                    : const SizedBox.shrink(),
              ),
              _buildInputSection(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyPreview(Entry replyingTo) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          top: BorderSide(color: Colors.blue.withOpacity(0.3)),
          bottom: BorderSide(color: Colors.blue.withOpacity(0.2)),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Icon(Icons.reply_rounded, color: Colors.blue, size: 22),
              );
            },
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(
                    'Replying to ${replyingTo.sender?.name ?? 'message'}',
                  ),
                ),

                SizedBox(height: 4.h),
                Text(
                  replyingTo.content ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.lightImpact();
                context.read<ChatCubit>().cancelReply();
                widget.onCancelReply?.call();
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(ChatState state) {
    return MainPadding(
      right: 16,
      bottom: widget.isGroup ? 0.h : 28.h,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            SizedBox(width: 10.w),
            if (!widget.isGroup) _buildFilePickerButton(state),
            SizedBox(width: 10.w),
            Expanded(child: _buildTextInput(state)),
            SizedBox(width: 6.w),
            _buildSendButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(ChatState state) {
    return TextFeildWidget(
      hintText: state.isReplying ?? false
          ? 'Reply to ${state.replyingTo?.sender?.name ?? 'message'}...'
          : 'Type a message',
      controller: _messageController,
      focusNode: _focusNode,
      inputBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xffCACACA), width: 1),
      ),
      hintStyle: TextStyle(
        color: state.isReplying ?? false ? Colors.blue[400] : Colors.grey[500],
      ),
      suffixIcon: _buildVoiceButton(),
      miniLength: 1,
      maxLines: 5,
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

  Widget _buildSendButton(ChatState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: state.isReplying ?? false ? Colors.blue : kPrimaryColor,
        shape: BoxShape.circle,
        boxShadow: _hasText
            ? [
                BoxShadow(
                  color:
                      (state.isReplying ?? false ? Colors.blue : kPrimaryColor)
                          .withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: AnimatedOpacity(
        opacity: _hasText || (state.selectedFiles?.isNotEmpty ?? false)
            ? 1.0
            : 0.0,
        duration: const Duration(milliseconds: 200),
        child: _hasText || (state.selectedFiles?.isNotEmpty ?? false)
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    child: Icon(
                      state.isReplying ?? false
                          ? Icons.reply
                          : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            : const SizedBox(width: 44, height: 44),
      ),
    );
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

    widget.onCancelReply?.call();
  }

  void _cancelRecording() {
    context.read<ChatCubit>().cancelRecording();
    _recordingAnimationController.stop();
    Navigator.pop(context);
  }
}
