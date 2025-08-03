import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedEmptyState extends StatefulWidget {
  final String selectedTab;

  const AnimatedEmptyState({super.key, required this.selectedTab});

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
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main animation controller for icon
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

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

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

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
    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _textController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _floatingController.repeat(reverse: true);
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
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
      animation: Listenable.merge([
        _mainController,
        _floatingController,
        _pulseController,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _iconSlideAnimation,
          child: FadeTransition(
            opacity: _iconFadeAnimation,
            child: Transform.translate(
              offset: Offset(0, _floatingAnimation.value),
              child: Transform.scale(
                scale: _iconScaleAnimation.value * _pulseAnimation.value,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: (_colorAnimation.value ?? Colors.grey[400])!
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_colorAnimation.value ?? Colors.grey[400])!
                            .withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getEmptyStateIcon(widget.selectedTab),
                    size: 60.sp,
                    color: _colorAnimation.value ?? Colors.grey[400],
                  ),
                ),
              ),
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
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Text(
                    _getEmptyStateTitle(widget.selectedTab),
                    style: TextStyle(
                      fontSize: 20,
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
          position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
              ),
            ),
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
          position: Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
                ),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _textController,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getThemeColor(
                            widget.selectedTab,
                          ).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _handleActionTap(),
                      icon: Icon(
                        _getActionIcon(widget.selectedTab),
                        size: 18.sp,
                      ),
                      label: Text(
                        _getActionText(widget.selectedTab),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getThemeColor(widget.selectedTab),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return Icons.groups_rounded;
      case 'Personal Chat':
      case 'personal':
        return Icons.person_rounded;
      case 'Broadcast':
      case 'broadcast':
        return Icons.campaign_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String _getEmptyStateTitle(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return 'No Group Chats';
      case 'Personal Chat':
      case 'personal':
        return 'No Personal Chats';
      case 'Broadcast':
      case 'broadcast':
        return 'No Broadcasts';
      default:
        return 'No Chats Available';
    }
  }

  String _getEmptyStateMessage(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return 'You haven\'t joined any group chats yet.\nCreate or join a group to start collaborating with your team.';
      case 'Personal Chat':
      case 'personal':
        return 'No personal conversations yet.\nStart chatting with your contacts to begin meaningful conversations.';
      case 'Broadcast':
      case 'broadcast':
        return 'No broadcast messages available.\nSubscribe to channels to stay updated with important announcements.';
      default:
        return 'No conversations available at the moment.\nStart a new chat to begin connecting with others.';
    }
  }

  Color _getThemeColor(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return Colors.green;
      case 'Personal Chat':
      case 'personal':
        return Colors.blue;
      case 'Broadcast':
      case 'broadcast':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return Icons.group_add_rounded;
      case 'Personal Chat':
      case 'personal':
        return Icons.person_add_rounded;
      case 'Broadcast':
      case 'broadcast':
        return Icons.notifications_active_rounded;
      default:
        return Icons.add_circle_outline_rounded;
    }
  }

  String _getActionText(String selectedTab) {
    switch (selectedTab) {
      case 'Group Chat':
      case 'group':
        return 'Create Group';
      case 'Personal Chat':
      case 'personal':
        return 'Start Chat';
      case 'Broadcast':
      case 'broadcast':
        return 'Browse Channels';
      default:
        return 'New Chat';
    }
  }

  void _handleActionTap() {
    switch (widget.selectedTab) {
      case 'Group Chat':
      case 'group':
        break;
      case 'Personal Chat':
      case 'personal':
        break;
      case 'Broadcast':
      case 'broadcast':
        break;
      default:
    }
  }
}
