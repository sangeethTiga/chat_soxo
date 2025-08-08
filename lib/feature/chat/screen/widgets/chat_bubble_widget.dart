import 'package:bubble/bubble.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/htm_Card.dart';
import 'package:soxo_chat/shared/constants/colors.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

class ChatBubbleMessage extends StatelessWidget {
  final String message;
  final String timestamp;
  final bool isSent;
  final String? senderName;
  final String? avatarPath;
  final bool showAvatar;
  final String? type;

  const ChatBubbleMessage({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.senderName,
    this.avatarPath,
    this.showAvatar = true,
    this.type,
  });

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
              _buildMessageContent(context, true, type ?? ''),
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
                  _buildMessageContent(context, false, type ?? ''),
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

  Widget _buildMessageContent(
    BuildContext context,
    bool isSentMessage,
    String html,
  ) {
    // if (html == 'html') {
    return FixedSizeHtmlWidget(htmlContent: message);
  }
  // {
  //   return Text('Hello');
  // }
  //  else {
  //   return _buildTextMessage(isSentMessage);
  // }
  // }

  Widget _buildTextMessage(bool isSentMessage) {
    return Text(
      message,
      style: isSentMessage
          ? const TextStyle(fontSize: 14, color: Color(0xFF4C4C4C))
          : FontPalette.hW500S14.copyWith(color: const Color(0XFF4C4C4C)),
    );
  }
}
