import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedEmptyState extends StatefulWidget {
  final String selectedTab;
  final VoidCallback? onActionPressed;
  final Duration mainAnimationDuration;
  final Duration floatingAnimationDuration;
  final Duration pulseAnimationDuration;
  final Duration textAnimationDuration;

  const AnimatedEmptyState({
    super.key,
    required this.selectedTab,
    this.onActionPressed,
    this.mainAnimationDuration = const Duration(milliseconds: 1200),
    this.floatingAnimationDuration = const Duration(milliseconds: 3000),
    this.pulseAnimationDuration = const Duration(milliseconds: 2000),
    this.textAnimationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _descriptionFadeAnimation;
  late Animation<Offset> _descriptionSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<Color?> _colorAnimation;

  // Timers for cleanup
  Timer? _textDelayTimer;
  Timer? _floatingDelayTimer;
  Timer? _pulseDelayTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Initialize controllers with configurable durations
    _mainController = AnimationController(
      duration: widget.mainAnimationDuration,
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: widget.floatingAnimationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: widget.pulseAnimationDuration,
      vsync: this,
    );

    _textController = AnimationController(
      duration: widget.textAnimationDuration,
      vsync: this,
    );

    // Icon animations
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _iconSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
          ),
        );

    // Text animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    // Description animations
    _descriptionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _descriptionSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );

    // Button animations
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
          ),
        );

    // Floating animation
    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Color animation
    _colorAnimation =
        ColorTween(
          begin: Colors.grey[400],
          end: _getThemeColor(widget.selectedTab),
        ).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );
  }

  void _startAnimations() {
    // Start main animation immediately
    _mainController.forward();

    // Start text animation with delay
    _textDelayTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    // Start floating animation with delay
    _floatingDelayTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _floatingController.repeat(reverse: true);
      }
    });

    // Start pulse animation with delay
    _pulseDelayTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    // Cancel all timers
    _textDelayTimer?.cancel();
    _floatingDelayTimer?.cancel();
    _pulseDelayTimer?.cancel();

    // Dispose all controllers
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedIcon(),
            SizedBox(height: 32.h),
            _buildAnimatedTitle(),
            SizedBox(height: 16.h),
            _buildAnimatedDescription(),
            SizedBox(height: 40.h),
            _buildAnimatedActionButton(),
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return SlideTransition(
          position: _iconSlideAnimation,
          child: FadeTransition(
            opacity: _iconFadeAnimation,
            child: _buildFloatingIcon(),
          ),
        );
      },
    );
  }

  Widget _buildFloatingIcon() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: _buildPulsingIcon(),
        );
      },
    );
  }

  Widget _buildPulsingIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScaleAnimation.value * _pulseAnimation.value,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: (_colorAnimation.value ?? Colors.grey[400])!.withOpacity(
                0.1,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_colorAnimation.value ?? Colors.grey[400])!
                      .withOpacity(0.2),
                  blurRadius: 20.r,
                  spreadRadius: 5.r,
                ),
              ],
            ),
            child: Icon(
              _getEmptyStateIcon(widget.selectedTab),
              size: 60.sp,
              color: _colorAnimation.value ?? Colors.grey[400],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: TweenAnimationBuilder<double>(
              duration: widget.textAnimationDuration,
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Text(
                    _getEmptyStateTitle(widget.selectedTab),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDescription() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _descriptionSlideAnimation,
          child: FadeTransition(
            opacity: _descriptionFadeAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _getEmptyStateMessage(widget.selectedTab),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedActionButton() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _buttonSlideAnimation,
          child: FadeTransition(
            opacity: _buttonFadeAnimation,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildActionButton(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: _getThemeColor(widget.selectedTab).withOpacity(0.3),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _handleActionTap,
        icon: Icon(_getActionIcon(widget.selectedTab), size: 18.sp),
        label: Text(
          _getActionText(widget.selectedTab),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getThemeColor(widget.selectedTab),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Helper methods remain the same but with improved error handling
  IconData _getEmptyStateIcon(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return Icons.groups_rounded;
      case 'personal chat':
      case 'personal':
        return Icons.person_rounded;
      case 'broadcast':
        return Icons.campaign_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _getEmptyStateTitle(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return 'No Group Chats';
      case 'personal chat':
      case 'personal':
        return 'No Personal Chats';
      case 'broadcast':
        return 'No Broadcasts';
      default:
        return 'No Chats Available';
    }
  }

  String _getEmptyStateMessage(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return 'You haven\'t joined any group chats yet.\nCreate or join a group to start collaborating with your team.';
      case 'personal chat':
      case 'personal':
        return 'No personal conversations yet.\nStart chatting with your contacts to begin meaningful conversations.';
      case 'broadcast':
        return 'No broadcast messages available.\nSubscribe to channels to stay updated with important announcements.';
      default:
        return 'No conversations available at the moment.\nStart a new chat to begin connecting with others.';
    }
  }

  Color _getThemeColor(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return const Color(0xFF4CAF50); // Material Green
      case 'personal chat':
      case 'personal':
        return const Color(0xFF2196F3); // Material Blue
      case 'broadcast':
        return const Color(0xFFFF9800); // Material Orange
      default:
        return const Color(0xFF9E9E9E); // Material Grey
    }
  }

  IconData _getActionIcon(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return Icons.group_add_rounded;
      case 'personal chat':
      case 'personal':
        return Icons.person_add_rounded;
      case 'broadcast':
        return Icons.notifications_active_rounded;
      default:
        return Icons.add_circle_outline_rounded;
    }
  }

  String _getActionText(String selectedTab) {
    switch (selectedTab.toLowerCase()) {
      case 'group chat':
      case 'group':
        return 'Create Group';
      case 'personal chat':
      case 'personal':
        return 'Start Chat';
      case 'broadcast':
        return 'Browse Channels';
      default:
        return 'New Chat';
    }
  }

  void _handleActionTap() {
    if (widget.onActionPressed != null) {
      widget.onActionPressed!();
    } else {
      _showDefaultAction();
    }
  }

  void _showDefaultAction() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getActionText(widget.selectedTab)} pressed'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
