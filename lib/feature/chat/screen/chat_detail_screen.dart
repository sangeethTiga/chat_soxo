import 'dart:developer';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:permission_handler/permission_handler.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/appbar.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/file_picker_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/record_dialog.dart';
import 'package:soxo_chat/shared/animation/empty_chat.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_category.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
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
    _messageController.dispose();
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: state.chatEntry?.entries?.length,
                    itemBuilder: (context, index) {
                      final data = state.chatEntry?.entries?[index];
                      log('data: ${data?.content}');

                      log('index: $index');
                      if (state.chatEntry?.entries?.isNotEmpty ?? false) {
                        log('data: ${data?.content}');
                        return Column(
                          children: [
                            SizedBox(height: 15.h),
                            ChatBubbleMessage(
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
                            _showPermissionDialog(context);
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
                  Padding(
                    padding: EdgeInsets.only(top: 5.h),
                    child: Container(
                      padding: EdgeInsets.only(left: 4.w),
                      alignment: Alignment.center,
                      height: 48.h,
                      width: 48.w,
                      decoration: BoxDecoration(
                        color: Color(0x99F1F1F1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: kPrimaryColor),
                    ),
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
                        _showPermissionDialog(context);
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
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: GestureDetector(
                  onTap: () {
                    context.read<ChatCubit>().createChat(
                      AddChatEntryRequest(chatId: widget.data?['chat_id']),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 4.w),
                    alignment: Alignment.center,
                    height: 48.h,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: Color(0x99F1F1F1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        28.verticalSpace,
      ],
    );
  }
}

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
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0XFFE3E3E3)),
            ),
            4.horizontalSpace,
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '3',
                style: FontPalette.hW600S14.copyWith(
                  color: const Color(0XFF9C27B0),
                ),
              ),
            ),
            8.horizontalSpace,
            GestureDetector(
              onTap: onArrowTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 35.h,
                width: 35.w,
                margin: EdgeInsets.only(right: 10.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFFEEF3F1),
                ),
                child: AnimatedBuilder(
                  animation: arrowAnimation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: (state.isArrow) == false
                          ? SvgPicture.asset('assets/icons/icon.svg')
                          : SvgPicture.asset('assets/icons/icon (1).svg'),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class GroupCardWidget extends StatelessWidget {
  const GroupCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MainPadding(
          bottom: 0,
          top: 16.h,
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
        Padding(
          padding: EdgeInsets.only(left: 34.w, top: 0.h, bottom: 0),
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

// class ChatBubbleMessage extends StatelessWidget {
//   final String message;
//   final String timestamp;
//   final bool isSent;
//   final String? senderName;
//   final String? avatarPath;
//   final bool showAvatar;

//   const ChatBubbleMessage({
//     super.key,
//     required this.message,
//     required this.timestamp,
//     required this.isSent,
//     this.senderName,
//     this.avatarPath,
//     this.showAvatar = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (isSent) {
//       return _buildSentMessage();
//     } else {
//       return _buildReceivedMessage();
//     }
//   }

//   Widget _buildSentMessage() {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         margin: EdgeInsets.only(bottom: 8.h, left: 50.w),
//         child: Bubble(
//           nip: BubbleNip.rightTop,
//           style: const BubbleStyle(elevation: 0, radius: Radius.circular(12)),
//           margin: const BubbleEdges.only(top: 10),
//           color: const Color(0xFFE8F5E8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 message,
//                 style: const TextStyle(fontSize: 14, color: Color(0xFF4C4C4C)),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(left: 65.w, top: 5.h),
//                 child: Text(
//                   timestamp,
//                   textAlign: TextAlign.end,
//                   style: FontPalette.hW400S14.copyWith(
//                     color: const Color(0XFFBBBBBB),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildReceivedMessage() {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h, right: 50.w),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.only(top: 10.h),
//             child: Image.asset(
//               'assets/images/Rectangle 1.png',
//               fit: BoxFit.cover,
//               height: 28.h,
//               width: 28.w,
//             ),
//           ),
//           5.horizontalSpace,
//           Expanded(
//             child: Bubble(
//               nip: BubbleNip.leftTop,
//               style: const BubbleStyle(
//                 elevation: 0,
//                 radius: Radius.circular(12),
//               ),
//               margin: const BubbleEdges.only(top: 10),
//               color: const Color(0x99F1F1F1),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     senderName ?? 'Dr Habeeb',
//                     style: FontPalette.hW500S14.copyWith(color: kGreenColor),
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           message,
//                           style: FontPalette.hW500S14.copyWith(
//                             color: const Color(0XFF4C4C4C),
//                           ),
//                         ),
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             timestamp,
//                             style: FontPalette.hW400S14.copyWith(
//                               color: const Color(0XFFBBBBBB),
//                             ),
//                           ),
//                           4.horizontalSpace,
//                           SvgPicture.asset('assets/icons/Receive.svg'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

void _showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Microphone Permission Required'),
      content: const Text(
        'This app needs microphone access to record voice messages. Please grant permission in settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('Settings'),
        ),
      ],
    ),
  );
}

class ChatBubbleMessage extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isSent;
  final String? senderName;
  final String? avatarPath;
  final bool showAvatar;

  const ChatBubbleMessage({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.senderName,
    this.avatarPath,
    this.showAvatar = true,
  });

  // Method to check if content is HTML
  bool _isHtmlContent(String content) {
    return content.trim().contains(RegExp(r'<[^>]*>')) &&
        (content.trim().startsWith('<') || content.contains('<!DOCTYPE'));
  }

  // Get title from HTML content
  String _getHtmlTitle(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      final title = document.querySelector('title')?.text;
      return title?.isNotEmpty == true ? title! : 'HTML Content';
    } catch (e) {
      return 'HTML Content';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSent) {
      return _buildSentMessage(context);
    } else {
      return _buildReceivedMessage(context);
    }
  }

  Widget _buildSentMessage(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, left: 50.w),
        child: Bubble(
          nip: BubbleNip.rightTop,
          style: const BubbleStyle(elevation: 0, radius: Radius.circular(12)),
          margin: const BubbleEdges.only(top: 10),
          color: const Color(0xFFE8F5E8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMessageContent(context, true),
              Padding(
                padding: EdgeInsets.only(left: 65.w, top: 5.h),
                child: Text(
                  timestamp,
                  textAlign: TextAlign.end,
                  style: FontPalette.hW400S14.copyWith(
                    color: const Color(0XFFBBBBBB),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h, right: 50.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Image.asset(
              'assets/images/Rectangle 1.png',
              fit: BoxFit.cover,
              height: 28.h,
              width: 28.w,
            ),
          ),
          5.horizontalSpace,
          Expanded(
            child: Bubble(
              nip: BubbleNip.leftTop,
              style: const BubbleStyle(
                elevation: 0,
                radius: Radius.circular(12),
              ),
              margin: const BubbleEdges.only(top: 10),
              color: const Color(0x99F1F1F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName ?? '',
                    style: FontPalette.hW500S14.copyWith(color: kGreenColor),
                  ),
                  const SizedBox(height: 4),
                  _buildMessageContent(context, false),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timestamp,
                        style: FontPalette.hW400S14.copyWith(
                          color: const Color(0XFFBBBBBB),
                        ),
                      ),
                      4.horizontalSpace,
                      SvgPicture.asset('assets/icons/Receive.svg'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isSentMessage) {
    if (_isHtmlContent(message)) {
      return FixedSizeHtmlWidget(
        htmlContent: message,
        isSentMessage: true,
      );
    } else {
      return _buildTextMessage(isSentMessage);
    }
  }

  Widget _buildTextMessage(bool isSentMessage) {
    return Text(
      message,
      style: isSentMessage
          ? const TextStyle(fontSize: 14, color: Color(0xFF4C4C4C))
          : FontPalette.hW500S14.copyWith(color: const Color(0XFF4C4C4C)),
    );
  }

  // Widget _buildHtmlMessage(BuildContext context, bool isSentMessage) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // HTML indicator
  //       Container(
  //         padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //         decoration: BoxDecoration(
  //           color: Colors.blue.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(4.r),
  //           border: Border.all(color: Colors.blue.withOpacity(0.3)),
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.web, size: 12.sp, color: Colors.blue[700]),
  //             SizedBox(width: 2.w),
  //             Text(
  //               'Web Content',
  //               style: TextStyle(
  //                 fontSize: 10.sp,
  //                 color: Colors.blue[700],
  //                 fontWeight: FontWeight.w500,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       SizedBox(height: 6.h),

  //       // Preview container
  //       Container(
  //         height: 1400.h,
  //         width: double.infinity,
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey.withOpacity(0.3)),
  //           borderRadius: BorderRadius.circular(8.r),
  //           color: Colors.white,
  //         ),
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(8.r),
  //           child: _buildHtmlPreview(),
  //         ),
  //       ),

  //       SizedBox(height: 8.h),

  //       // View full button
  //       GestureDetector(
  //         onTap: () => _showFullHtmlPage(context),
  //         child: Container(
  //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(6.r),
  //             border: Border.all(color: Colors.blue.withOpacity(0.3)),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(Icons.open_in_new, size: 14.sp, color: Colors.blue[700]),
  //               SizedBox(width: 4.w),
  //               Text(
  //                 'View Full Page',
  //                 style: TextStyle(
  //                   fontSize: 12.sp,
  //                   color: Colors.blue[700],
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildHtmlPreview() {
  //   return Html(
  //     data: message,
  //     style: {
  //       "body": Style(
  //         fontSize: FontSize(10.sp),
  //         margin: Margins.all(4),
  //         padding: HtmlPaddings.all(4),
  //       ),
  //       "*": Style(fontSize: FontSize(10.sp)),
  //     },
  //     onLinkTap: (url, attributes, element) {
  //       // Handle link taps if needed
  //       print('Link tapped: $url');
  //     },
  //   );
  // }

  // void _showFullHtmlPage(BuildContext context) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => HtmlViewerScreen(
  //         htmlContent: message,
  //         title: _getHtmlTitle(message),
  //       ),
  //     ),
  //   );
  // }
}

class HtmlViewerScreen extends StatefulWidget {
  final String htmlContent;
  final String title;

  const HtmlViewerScreen({
    super.key,
    required this.htmlContent,
    required this.title,
  });

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(widget.htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  // void _showOptionsBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => Container(
  //       padding: EdgeInsets.all(16.w),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.refresh),
  //             title: const Text('Refresh'),
  //             onTap: () {
  //               controller.reload();
  //               Navigator.pop(context);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.code),
  //             title: const Text('View Source'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _showHtmlSource(context);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showHtmlSource(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       insetPadding: EdgeInsets.all(16.w),
  //       child: Container(
  //         width: double.infinity,
  //         height: MediaQuery.of(context).size.height * 0.8,
  //         padding: EdgeInsets.all(16.w),
  //         child: Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'HTML Source',
  //                   style: TextStyle(
  //                     fontSize: 18.sp,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 IconButton(
  //                   onPressed: () => Navigator.pop(context),
  //                   icon: const Icon(Icons.close),
  //                 ),
  //               ],
  //             ),
  //             const Divider(),
  //             Expanded(
  //               child: SingleChildScrollView(
  //                 child: Container(
  //                   width: double.infinity,
  //                   padding: EdgeInsets.all(12.w),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey[100],
  //                     borderRadius: BorderRadius.circular(8.r),
  //                   ),
  //                   child: Text(
  //                     widget.htmlContent,
  //                     style: TextStyle(
  //                       fontSize: 12.sp,
  //                       fontFamily: 'monospace',
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
