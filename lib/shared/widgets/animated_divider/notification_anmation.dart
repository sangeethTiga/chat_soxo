import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedNotificationBell extends StatefulWidget {
  final int notificationCount;
  final VoidCallback? onTap;
  final Color badgeColor;
  final Color textColor;
  final String iconPath;
  final bool autoAnimate;
  final Duration animationInterval;

  const AnimatedNotificationBell({
    super.key,
    this.notificationCount = 0,
    this.onTap,
    this.badgeColor = const Color(0xFFE42168),
    this.textColor = Colors.white,
    this.iconPath = 'assets/icons/bell.svg',
    this.autoAnimate = true,
    this.animationInterval = const Duration(seconds: 3),
  });

  @override
  State<AnimatedNotificationBell> createState() =>
      _AnimatedNotificationBellState();
}

class _AnimatedNotificationBellState extends State<AnimatedNotificationBell>
    with TickerProviderStateMixin {
  late AnimationController _bellController;
  late AnimationController _badgeController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  late Animation<double> _bellSwingAnimation;
  late Animation<double> _badgeScaleAnimation;
  late Animation<double> _badgePulseAnimation;
  late Animation<double> _glowAnimation;

  Timer? _autoAnimationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    if (widget.autoAnimate && widget.notificationCount > 0) {
      _startAutoAnimation();
    }
  }

  void _initializeAnimations() {
    _bellController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bellSwingAnimation = Tween<double>(begin: -0.15, end: 0.15).animate(
      CurvedAnimation(parent: _bellController, curve: Curves.elasticOut),
    );
    _badgeScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _badgeController, curve: Curves.elasticOut),
    );

    _badgePulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startAutoAnimation() {
    _autoAnimationTimer?.cancel();
    _autoAnimationTimer = Timer.periodic(widget.animationInterval, (timer) {
      if (mounted && widget.notificationCount > 0) {
        _triggerNotificationAnimation();
      }
    });

    // Initial animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _triggerNotificationAnimation();
    });
  }

  void _triggerNotificationAnimation() {
    // Bell swing animation
    _bellController.forward().then((_) {
      if (mounted) {
        _bellController.reverse().then((_) {
          if (mounted) _bellController.reset();
        });
      }
    });

    // Badge scale animation with delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _badgeController.forward().then((_) {
          if (mounted) {
            _badgeController.reverse().then((_) {
              if (mounted) _badgeController.reset();
            });
          }
        });
      }
    });

    // Pulse and glow animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat(reverse: true);

        // Stop pulse after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _pulseController.stop();
            _glowController.stop();
            _pulseController.reset();
            _glowController.reset();
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedNotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when notification count changes
    if (widget.notificationCount != oldWidget.notificationCount &&
        widget.notificationCount > 0) {
      _triggerNotificationAnimation();
    }

    // Start/stop auto animation based on notification count
    if (widget.autoAnimate && widget.notificationCount > 0) {
      _startAutoAnimation();
    } else {
      _autoAnimationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _autoAnimationTimer?.cancel();
    _bellController.dispose();
    _badgeController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Trigger animation on tap
        _triggerNotificationAnimation();
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bellController,
          _badgeController,
          _pulseController,
          _glowController,
        ]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _bellSwingAnimation.value,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.notificationCount > 0)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.badgeColor.withOpacity(
                                  0.3 * _glowAnimation.value,
                                ),
                                blurRadius: 20 * _glowAnimation.value,
                                spreadRadius: 5 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                Transform.scale(
                  scale: 0.9,
                  child: SvgPicture.asset(
                    widget.iconPath,
                    height: 25.h,
                    width: 25.w,
                  ),
                ),
                if (widget.notificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Transform.scale(
                      scale:
                          (_badgeScaleAnimation.value.clamp(0.5, 2.0)) *
                          (_badgePulseAnimation.value.clamp(0.8, 1.3)),
                      child: Container(
                        alignment: Alignment.center,
                        width: 14.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: widget.badgeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.badgeColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          widget.notificationCount > 99
                              ? '99+'
                              : widget.notificationCount.toString(),
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w400,
                            color: widget.textColor,
                          ),
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
}
