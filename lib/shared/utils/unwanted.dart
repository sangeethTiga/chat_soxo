// class UnifiedMessageInput extends StatefulWidget {
//   final Map<String, dynamic>? chatData;
//   final bool isGroup;
//   final Entry? replyingTo; // 🔑 NEW: Reply support
//   final VoidCallback? onCancelReply; // 🔑 NEW: Cancel reply

//   const UnifiedMessageInput({
//     super.key,
//     this.chatData,
//     this.isGroup = false,
//     this.replyingTo,
//     this.onCancelReply,
//   });

//   @override
//   State<UnifiedMessageInput> createState() => _UnifiedMessageInputState();
// }

// class _UnifiedMessageInputState extends State<UnifiedMessageInput>
//     with SingleTickerProviderStateMixin {
//   late TextEditingController _messageController;
//   late AnimationController _recordingAnimationController;
//   late Animation<double> _pulseAnimation;

//   bool _hasText = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//   }

//   void _initializeControllers() {
//     _messageController = TextEditingController();
//     _messageController.addListener(_onTextChanged);

//     _recordingAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
//       CurvedAnimation(
//         parent: _recordingAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _recordingAnimationController.dispose();
//     _messageController.removeListener(_onTextChanged);
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _onTextChanged() {
//     final hasText = _messageController.text.trim().isNotEmpty;
//     if (hasText != _hasText) {
//       setState(() => _hasText = hasText);
//     }
//   }

//   Future<void> _sendMessage() async {
//     final messageText = _messageController.text.trim();
//     final user = await AuthUtils.instance.readUserData();
//     final bool isReply = widget.replyingTo != null;

//     if (widget.isGroup) {
//       _handleGroupMessage(messageText);
//       return;
//     }

//     final selectedFiles = context.read<ChatCubit>().state.selectedFiles ?? [];
//     if (messageText.isEmpty && selectedFiles.isEmpty) return;

//     _messageController.clear();
//     String? otherDetails1;
//     if (isReply) {
//       final replyDetails = [
//         {"ReplayChatEntryId": widget.replyingTo!.id.toString()},
//       ];
//       otherDetails1 = jsonEncode(replyDetails);
//     }

//     log("Stringfied -=- =- =- =- =- =- =- =-= -=- = $otherDetails1");
//     // 🔑 Include reply information if replying
//     await context.read<ChatCubit>().createChat(
//       AddChatEntryRequest(
//         chatId: widget.chatData?['chat_id'],
//         senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
//         type: isReply ? 'CR' : 'N',
//         typeValue: 0,
//         messageType: 'text',
//         content: messageText.isNotEmpty ? messageText : 'File attachment',
//         source: 'Website',
//         attachedFiles: selectedFiles,
//         otherDetails1: otherDetails1, // 🔑 Pass the reply information
//       ),
//       files: selectedFiles,
//     );

//     // Clear reply after sending
//     widget.onCancelReply?.call();

//     log('Message sent: $messageText');
//   }

//   void _handleGroupMessage(String messageText) {
//     if (messageText.isEmpty) return;

//     _messageController.clear();
//     FocusScope.of(context).unfocus();

//     // Clear reply after sending
//     widget.onCancelReply?.call();

//     log('Group message sent: $messageText');
//   }

//   // ... rest of your existing methods remain the same

//   Widget _buildTextInput() {
//     return TextFeildWidget(
//       hintText: widget.replyingTo != null
//           ? 'Reply to ${widget.replyingTo!.sender?.name ?? 'User'}...'
//           : 'Type a message',
//       controller: _messageController,
//       inputBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(10.r),
//         borderSide: const BorderSide(color: Color(0xffCACACA), width: 1),
//       ),
//       suffixIcon: _buildVoiceButton(),
//       miniLength: 1,
//       maxLines: 5,
//     );
//   }

//   // ... include all your other existing methods like _buildVoiceButton, _buildSendButton, etc.

//   @override
//   Widget build(BuildContext context) {
//     return MainPadding(
//       right: 16,
//       bottom: widget.isGroup ? 0.h : 28.h,
//       child: Row(
//         children: [
//           SizedBox(width: 10.w),
//           if (!widget.isGroup)
//             _buildFilePickerButton(context.watch<ChatCubit>().state),
//           SizedBox(width: 10.w),
//           Expanded(child: _buildTextInput()),
//           SizedBox(width: 6.w),
//           _buildSendButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilePickerButton(ChatState state) {
//     return InkWell(
//       onTap: () => showFilePickerBottomSheet(context),
//       child: (state.selectedFiles?.isNotEmpty ?? false)
//           ? Badge.count(
//               backgroundColor: kPrimaryColor,
//               count: state.selectedFiles?.length ?? 0,
//               child: SvgPicture.asset('assets/icons/Vector.svg'),
//             )
//           : SvgPicture.asset('assets/icons/Vector.svg'),
//     );
//   }

//   Widget _buildVoiceButton() {
//     return BlocSelector<ChatCubit, ChatState, bool>(
//       selector: (state) => state.hasRecordingPermission,
//       builder: (context, hasPermission) {
//         return InkWell(
//           onTap: hasPermission
//               ? _startRecording
//               : () => showPermissionDialog(context),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SvgPicture.asset('assets/icons/Group 1000006770.svg'),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSendButton() {
//     return AnimatedOpacity(
//       opacity: _hasText ? 1.0 : 0.0,
//       duration: const Duration(milliseconds: 200),
//       child: _hasText
//           ? Padding(
//               padding: EdgeInsets.only(top: 5.h),
//               child: GestureDetector(
//                 onTap: _sendMessage,
//                 child: Container(
//                   padding: EdgeInsets.only(left: 4.w),
//                   alignment: Alignment.center,
//                   height: 48.h,
//                   width: 48.w,
//                   decoration: const BoxDecoration(
//                     color: kPrimaryColor,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.send, color: Colors.white),
//                 ),
//               ),
//             )
//           : const SizedBox.shrink(),
//     );
//   }

//   void _startRecording() {
//     final chatCubit = context.read<ChatCubit>();
//     chatCubit.startRecording();
//     _recordingAnimationController.repeat(reverse: true);

//     showRecordingDialog(
//       context,
//       _pulseAnimation,
//       _cancelRecording,
//       _stopRecording,
//     );
//   }

//   void _stopRecording() async {
//     final user = await AuthUtils.instance.readUserData();
//     if (!widget.isGroup) {
//       context.read<ChatCubit>().stopRecordingAndSend(
//         AddChatEntryRequest(
//           chatId: widget.chatData?['chat_id'],
//           senderId: int.tryParse(user?.result?.userId.toString() ?? '1'),
//           type: 'N',
//           typeValue: 0,
//           messageType: 'voice',
//           content: 'Voice message',
//           source: 'Mobile',
//         ),
//       );
//     }

//     _recordingAnimationController.stop();
//     Navigator.pop(context);

//     // Clear reply after sending voice message
//     widget.onCancelReply?.call();
//   }

//   void _cancelRecording() {
//     context.read<ChatCubit>().cancelRecording();
//     _recordingAnimationController.stop();
//     Navigator.pop(context);
//   }
// }

// class AnimatedDividerCard extends StatelessWidget {
//   final VoidCallback onArrowTap;
//   final Animation<double> arrowAnimation;

//   const AnimatedDividerCard({
//     super.key,
//     required this.onArrowTap,
//     required this.arrowAnimation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onArrowTap,
//       child: Container(
//         padding: EdgeInsets.only(left: 0.w, right: 12, top: 0, bottom: 0),
//         child: Row(
//           children: [
//             const Expanded(child: Divider()),
//             2.horizontalSpace,
//             AnimatedBuilder(
//               animation: arrowAnimation,
//               builder: (context, child) {
//                 return Transform.rotate(
//                   angle: arrowAnimation.value * 6.28,
//                   child: Container(
//                     height: 25.h,
//                     width: 25.w,
//                     decoration: BoxDecoration(
//                       color: Color(0XFFEEF3F1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(6.0),
//                       child: SvgPicture.asset('assets/icons/icon.svg'),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
