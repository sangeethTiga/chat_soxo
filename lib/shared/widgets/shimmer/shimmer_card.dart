import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerLoadingWidget extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;
  final String mediaType;

  const ShimmerLoadingWidget({
    super.key,
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
    this.mediaType = 'unknown',
  });

  @override
  Widget build(BuildContext context) {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return ImageShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case 'audio':
      case 'voice':
        return AudioShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case 'document':
      case 'pdf':
        return DocumentShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      default:
        return _GenericShimmer(
          isInChatBubble: isInChatBubble,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
    }
  }
}

/// Image-specific shimmer
class ImageShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const ImageShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 200.w : double.infinity),
        height: maxHeight ?? (isInChatBubble ? 150.h : 200.h),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: isInChatBubble ? 32.sp : 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8.h),
            Container(
              width: 60.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Audio-specific shimmer
class AudioShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const AudioShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 250.w : 300.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Container(
                width: isInChatBubble ? 32.w : 40.w,
                height: isInChatBubble ? 32.h : 40.h,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 40.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document-specific shimmer
class DocumentShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const DocumentShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 150.w : 200.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Container(
                width: isInChatBubble ? 24.w : 32.w,
                height: isInChatBubble ? 24.h : 32.h,
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.red[300],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 60.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: Colors.red[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic shimmer for unknown media types
class _GenericShimmer extends StatelessWidget {
  final bool isInChatBubble;
  final double? maxWidth;
  final double? maxHeight;

  const _GenericShimmer({
    required this.isInChatBubble,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: maxWidth ?? (isInChatBubble ? 120.w : 150.w),
        height: maxHeight ?? (isInChatBubble ? 60.h : 80.h),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 40.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
