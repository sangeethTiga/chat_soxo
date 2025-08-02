import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _arrowRotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Arrow rotation animation
    _arrowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Content transition animation
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _arrowRotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.5, // 180 degrees rotation
        ).animate(
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
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _handleArrowTap() {
    context.read<ChatCubit>().arrowSelected();

    // Animate arrow rotation
    if (_arrowAnimationController.isCompleted) {
      _arrowAnimationController.reverse();
    } else {
      _arrowAnimationController.forward();
    }

    // Animate content transition
    _contentAnimationController.reset();
    _contentAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFB7E8CA), Color(0xFFF2F2F2)],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
                child: SafeArea(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5.w),
                        alignment: Alignment.center,
                        height: 39.h,
                        width: 39.w,
                        decoration: BoxDecoration(
                          color: kWhite,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      6.horizontalSpace,
                      Image.asset('assets/images/Avatar.png'),
                      6.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mathew', style: FontPalette.hW400S18),
                          Row(
                            children: [
                              Container(
                                height: 8.h,
                                width: 8.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFF68D391),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              5.horizontalSpace,
                              Text('Online', style: FontPalette.hW600S12),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  transform: Matrix4.translationValues(0, -20, 0),
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
                    child: state.isArrow == false
                        ? _buildChatContent(key: ValueKey('chat'))
                        : _buildGroupContent(key: ValueKey('group')),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatContent({required Key key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainPadding(
          top: 25.h,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/mynaui_pin-solid.svg'),
              5.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Image.asset('assets/images/Rectangle 1.png')],
              ),
              5.horizontalSpace,
              SizedBox(
                width: 240.w,
                child: RichText(
                  text: TextSpan(
                    text: 'Anoop TS  ',
                    style: FontPalette.hW700S14.copyWith(
                      color: Color(0XFF515978),
                    ),
                    children: [
                      TextSpan(
                        text: 'send request to case',
                        style: FontPalette.hW500S14.copyWith(
                          color: Color(0XFF515978),
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Spacer(),
              SvgPicture.asset('assets/icons/clock.svg'),
              5.horizontalSpace,
              Text('45 min'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 34.w, top: 0.h),
          child: Row(
            children: [
              Text(
                '3 Replayed , 4 Pending',
                style: FontPalette.hW500S12.copyWith(color: Color(0XFF166FF6)),
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
        MainPadding(
          child: Column(
            children: [
              15.verticalSpace,
              const ChatBubbleMessage(
                message: 'Thank you for confirmation',
                timestamp: '12-2-2025 ,15:24',
                isSent: true,
              ),
              const ChatBubbleMessage(
                message: 'You are welcome',
                timestamp: '12-2-2025 ,15:24',
                isSent: false,
                senderName: 'Dr Habeeb',
                showAvatar: true,
              ),
            ],
          ),
        ),
        Spacer(),
        Row(
          children: [
            13.horizontalSpace,
            SvgPicture.asset('assets/icons/Vector.svg'),
            10.horizontalSpace,
            Expanded(
              child: TextFeildWidget(
                hintStyle: FontPalette.hW400S16.copyWith(
                  color: Color(0XFFBFBFBF),
                ),
                hight: 48.h,
                fillColor: kWhite,
                hintText: 'Type a message',
                inputBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: Color(0xffCACACA), width: 1),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset('assets/icons/Group 1000006770.svg'),
                ),
              ),
            ),
            16.horizontalSpace,
          ],
        ),
        15.verticalSpace,
      ],
    );
  }

  Widget _buildGroupContent({required Key key}) {
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
                position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
                    .animate(
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
                  child: GroupCardWidget(),
                ),
              ),
            );
          },
          separatorBuilder: (context, i) {
            return Divider(color: Color(0XFFE3E3E3), thickness: 0);
          },
          itemCount: 3,
        ),
        // ...List.generate(
        //   3,
        //   (index) => AnimatedContainer(
        //     duration: Duration(milliseconds: 200 + (index * 100)),
        //     curve: Curves.easeOutBack,
        //     child: SlideTransition(
        //       position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
        //           .animate(
        //             CurvedAnimation(
        //               parent: _contentAnimationController,
        //               curve: Interval(
        //                 index * 0.2,
        //                 0.6 + (index * 0.2),
        //                 curve: Curves.easeOutCubic,
        //               ),
        //             ),
        //           ),
        //       child: FadeTransition(
        //         opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        //           CurvedAnimation(
        //             parent: _contentAnimationController,
        //             curve: Interval(
        //               index * 0.1,
        //               0.5 + (index * 0.1),
        //               curve: Curves.easeIn,
        //             ),
        //           ),
        //         ),
        //         child: GroupCardWidget(),
        //       ),
        //     ),
        //   ),
        // ),
        Spacer(),
        AnimatedDividerCard(
          onArrowTap: _handleArrowTap,
          arrowAnimation: _arrowRotationAnimation,
        ),
        10.verticalSpace,
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
            Expanded(child: Divider(thickness: 1, color: Color(0XFFE3E3E3))),
            4.horizontalSpace,
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '3',
                style: FontPalette.hW600S14.copyWith(color: Color(0XFF9C27B0)),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0XFFEEF3F1),
                ),
                child: AnimatedBuilder(
                  animation: arrowAnimation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: state.isArrow == false
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Image.asset('assets/images/Rectangle 1.png')],
              ),
              5.horizontalSpace,
              SizedBox(
                width: 240.w,
                child: RichText(
                  text: TextSpan(
                    text: 'Anoop TS  ',
                    style: FontPalette.hW700S14.copyWith(
                      color: Color(0XFF515978),
                    ),
                    children: [
                      TextSpan(
                        text: 'send request to case',
                        style: FontPalette.hW500S14.copyWith(
                          color: Color(0XFF515978),
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Spacer(),
              SvgPicture.asset('assets/icons/clock.svg'),
              5.horizontalSpace,
              Text('45 min'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 34.w, top: 0.h, bottom: 0),
          child: Row(
            children: [
              Text(
                '3 Replayed , 4 Pending',
                style: FontPalette.hW500S12.copyWith(color: Color(0XFF166FF6)),
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

  @override
  Widget build(BuildContext context) {
    if (isSent) {
      return _buildSentMessage();
    } else {
      return _buildReceivedMessage();
    }
  }

  Widget _buildSentMessage() {
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
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Color(0xFF4C4C4C)),
              ),
              Padding(
                padding: EdgeInsetsGeometry.only(left: 65.w, top: 5.h),
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

  Widget _buildReceivedMessage() {
    return Container(
      margin: EdgeInsets.only(bottom: 0.h, right: 50.w),
      child: Row(
        children: [
          Image.asset(
            'assets/images/Rectangle 1.png',
            fit: BoxFit.cover,
            height: 28.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.w, top: 8.h),
            child: Bubble(
              nip: BubbleNip.leftTop,
              style: const BubbleStyle(
                elevation: 0,
                radius: Radius.circular(12),
              ),
              margin: BubbleEdges.only(top: 10),
              color: Color(0x99F1F1F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr Habeeb',
                    textAlign: TextAlign.right,
                    style: FontPalette.hW500S14.copyWith(color: kGreenColor),
                  ),
                  Row(
                    children: [
                      Text(
                        'No',
                        style: FontPalette.hW500S14.copyWith(
                          color: Color(0XFF4C4C4C),
                        ),
                      ),
                      50.horizontalSpace,
                      Text(
                        '12-2-2025 ,15:23',
                        textAlign: TextAlign.right,
                        style: FontPalette.hW400S14.copyWith(
                          color: Color(0XFFBBBBBB),
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
}
