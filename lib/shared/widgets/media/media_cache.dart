import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_bubble_widget.dart';

class MediaCache {
  static final Map<String, Uint8List> _imageCache = {};
  static final Map<String, String> _filePathCache = {};
  static final Set<String> _loadingItems = {};
  static final Set<String> _failedItems = {};

  static Uint8List? getImage(String key) => _imageCache[key];
  static void setImage(String key, Uint8List data) {
    _imageCache[key] = data;
    _failedItems.remove(key);
  }

  static void clearFilePath(String mediaId) {
    _failedItems.remove(mediaId);
  }

  static void clearAll() {
    _failedItems.clear();
    _imageCache.clear();
    _filePathCache.clear();
    _loadingItems.clear();
  }

  static String? getFilePath(String key) => _filePathCache[key];
  static void setFilePath(String key, String path) {
    _filePathCache[key] = path;
    _failedItems.remove(key);
  }

  static bool isLoading(String key) => _loadingItems.contains(key);
  static void setLoading(String key) {
    _loadingItems.add(key);
    _failedItems.remove(key);
  }

  static void clearLoading(String key) => _loadingItems.remove(key);

  static bool hasFailed(String key) => _failedItems.contains(key);
  static void setFailed(String key) {
    _failedItems.add(key);
    _loadingItems.remove(key);
  }

  static void clearFailed(String key) => _failedItems.remove(key);

  static void clear() {
    _imageCache.clear();
    _filePathCache.clear();
    _loadingItems.clear();
    _failedItems.clear();
  }

  static void clearForMedia(String key) {
    _imageCache.remove(key);
    _filePathCache.remove(key);
    _loadingItems.remove(key);
    _failedItems.remove(key);
  }
}

class MessageOptionsBottomSheet extends StatelessWidget {
  final String message;
  final bool isSent;
  final bool isPinned;
  final bool isBeingRepliedTo;
  final VoidCallback? onReply;
  final VoidCallback? onPin;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;
  final VoidCallback? onDeleteEveryOne;
  final VoidCallback? clearChat;
  final VoidCallback? onforward;

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
    required this.isSent,
    required this.isPinned,
    this.isBeingRepliedTo = false,
    this.onReply,
    this.onPin,
    this.onCopy,
    this.onDelete,
    this.onDeleteEveryOne,
    this.clearChat,
    this.onforward,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            if (message.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  message.length > 50
                      ? '${message.substring(0, 50)}...'
                      : message,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14.sp,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey[200],
                indent: 20.w,
                endIndent: 20.w,
              ),
            ],

            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.h),
                  child: Column(
                    children: [
                      _buildOption(
                        icon: Icons.reply_rounded,
                        title: 'Reply',
                        onTap: onReply,
                        isHighlighted: isBeingRepliedTo,
                      ),
                      _buildOption(
                        icon: isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        title: isPinned ? 'Unpin Message' : 'Pin Message',
                        onTap: onPin,
                      ),
                      _buildOption(
                        icon: Icons.content_copy_rounded,
                        title: 'Copy Text',
                        onTap: onCopy,
                      ),
                      _buildOption(
                        icon: Icons.forward,
                        title: 'Forward',
                        onTap: onforward,
                      ),

                      Divider(
                        height: 24.h,
                        thickness: 1,
                        color: Colors.grey[200],
                        indent: 20.w,
                        endIndent: 20.w,
                      ),

                      _buildOption(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete for Me',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                      if (isSent)
                        _buildOption(
                          icon: Icons.delete_sweep_outlined,
                          title: 'Delete for Everyone',
                          onTap: onDeleteEveryOne,
                          isDestructive: true,
                        ),
                      _buildOption(
                        icon: Icons.clear_all_rounded,
                        title: 'Clear Chat',
                        onTap: clearChat,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isHighlighted = false,
  }) {
    final primaryColor = isDestructive
        ? Colors.red[600]!
        : isHighlighted
        ? Colors.blue[600]!
        : Colors.grey[800]!;

    final backgroundColor = isHighlighted
        ? Colors.blue[50]!
        : Colors.transparent;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: isHighlighted
            ? Border.all(color: Colors.blue[200]!, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          highlightColor: isDestructive
              ? Colors.red.withOpacity(0.05)
              : Colors.grey.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: primaryColor, size: 20.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red[700] : Colors.grey[800],
                      fontSize: 14.sp,
                      fontWeight: isHighlighted
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (isHighlighted) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.blue[700],
                      size: 16.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MediaContainer extends StatelessWidget {
  final ChatMedias media;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const MediaContainer({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        child: OptimizedMediaPreview(
          media: media,
          maxWidth: width,
          maxHeight: height,
        ),
      ),
    );
  }
}
