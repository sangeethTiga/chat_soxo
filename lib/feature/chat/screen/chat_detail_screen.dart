import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/enhanced_widget.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/opmiized_card.dart';
import 'package:soxo_chat/shared/widgets/animated_divider/animated_divider.dart';
import 'package:soxo_chat/shared/widgets/appbar/appbar.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const ChatDetailScreen({super.key, this.data});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowRotationAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    context.read<ChatCubit>().resetChatState();
    _loadChatData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _arrowRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleViewToggle() {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.arrowSelected();

    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _loadChatData() {
    final chatId = widget.data?['chat_id'];
    if (chatId != null) {
      context.read<ChatCubit>().getChatEntry(chatId: chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithProfile(context, {}, title: widget.data?['title']),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: _handleErrorMessage,
        child: _buildBody(),
      ),
    );
  }

  void _handleErrorMessage(BuildContext context, ChatState state) {
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => context.read<ChatCubit>().clearError(),
          ),
        ),
      );
    }
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
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
              child: BlocSelector<ChatCubit, ChatState, bool>(
                selector: (state) => state.isArrow,
                builder: (context, isArrow) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: isArrow
                        ? GroupContent(
                            data: widget.data,
                            key: const ValueKey('group'),
                            onToggleTap: _handleViewToggle,
                            arrowAnimation: _arrowRotationAnimation,
                            contentAnimation: _contentFadeAnimation,
                          )
                        : ChatContent(
                            key: const ValueKey('chat'),
                            data: widget.data,
                            onToggleTap: _handleViewToggle,
                            arrowAnimation: _arrowRotationAnimation,
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatContent extends StatefulWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onToggleTap;
  final Animation<double> arrowAnimation;

  const ChatContent({
    super.key,
    this.data,
    required this.onToggleTap,
    required this.arrowAnimation,
  });

  @override
  State<ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<ChatContent>
    with TickerProviderStateMixin {
  late AnimationController _replyAnimationController;
  late Animation<double> _replyScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _replyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _replyScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _replyAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _replyAnimationController.dispose();
    super.dispose();
  }

  void _startReply(Entry message) {
    context.read<ChatCubit>().startReply(message);
    _replyAnimationController.forward();
    HapticFeedback.lightImpact();
    log('🔄 Started reply to message: ${message.id}');
  }

  void _cancelReply() {
    context.read<ChatCubit>().cancelReply();
    _replyAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        final pinnedEntries =
            chatState.chatEntry?.entries
                ?.where((e) => (e.pinned ?? '').trim().toUpperCase() == 'Y')
                .toList() ??
            [];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: chatState.isReplying ?? false
                ? Colors.blue.withOpacity(0.02)
                : Colors.white,
          ),
          child: Column(
            children: [
              if (pinnedEntries.isNotEmpty) ...{
                GroupCardWidget(
                  title: pinnedEntries[0].sender?.name,
                  imageUrl: pinnedEntries[0].sender?.imageUrl,
                ),
                AnimatedDividerCard(
                  onArrowTap: widget.onToggleTap,
                  arrowAnimation: widget.arrowAnimation,
                ),
              },

              Expanded(
                child: OptimizedChatMessagesLists(
                  onReplyMessage: _startReply,
                  currentReplyingTo: chatState.replyingTo,
                  isReplying: chatState.isReplying ?? false,
                  chatData: widget.data,
                ),
              ),

              14.verticalSpace,
              AnimatedBuilder(
                animation: _replyScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: chatState.isReplying ?? false
                        ? _replyScaleAnimation.value
                        : 1.0,
                    child: EnhancedUnifiedMessageInput(
                      chatData: widget.data,
                      onCancelReply: _cancelReply,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnhancedChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const EnhancedChatDetailScreen({super.key, this.data});

  @override
  State<EnhancedChatDetailScreen> createState() =>
      _EnhancedChatDetailScreenState();
}

class _EnhancedChatDetailScreenState extends State<EnhancedChatDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowRotationAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    context.read<ChatCubit>().resetChatState();
    _loadChatData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _arrowRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleViewToggle() {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.arrowSelected();

    if (_animationController.isCompleted) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _loadChatData() {
    final chatId = widget.data?['chat_id'];
    if (chatId != null) {
      context.read<ChatCubit>().getChatEntry(chatId: chatId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildEnhancedAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data?['title'] ?? 'Chat',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // ✅ Show reply status in app bar
              if (state.isReplying ?? false)
                Text(
                  'Replying to ${state.replyingTo?.sender?.name ?? 'message'}...',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            if (state.isReplying ?? false) {
              return IconButton(
                onPressed: () {
                  context.read<ChatCubit>().cancelReply();
                },
                icon: Icon(Icons.close, color: Colors.blue),
                tooltip: 'Cancel Reply',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
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
              child: BlocSelector<ChatCubit, ChatState, bool>(
                selector: (state) => state.isArrow,
                builder: (context, isArrow) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: isArrow
                        ? GroupContent(
                            data: widget.data,
                            key: const ValueKey('group'),
                            onToggleTap: _handleViewToggle,
                            arrowAnimation: _arrowRotationAnimation,
                            contentAnimation: _contentFadeAnimation,
                          )
                        : ChatContent(
                            key: const ValueKey('chat'),
                            data: widget.data,
                            onToggleTap: _handleViewToggle,
                            arrowAnimation: _arrowRotationAnimation,
                          ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupContent extends StatefulWidget {
  final VoidCallback onToggleTap;
  final Animation<double> arrowAnimation;
  final Animation<double> contentAnimation;
  final Map<String, dynamic>? data;

  const GroupContent({
    super.key,
    required this.onToggleTap,
    required this.arrowAnimation,
    required this.contentAnimation,
    required this.data,
  });

  @override
  State<GroupContent> createState() => _GroupContentState();
}

class _GroupContentState extends State<GroupContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _replyAnimationController;
  late Animation<double> _replyScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _replyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _replyScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _replyAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _replyAnimationController.dispose();
    super.dispose();
  }

  // void _startReply(Entry message) {
  //   context.read<ChatCubit>().startReply(message);
  //   _replyAnimationController.forward();
  //   HapticFeedback.lightImpact();
  //   log('🔄 Started reply to message: ${message.id}');
  // }

  void _cancelReply() {
    context.read<ChatCubit>().cancelReply();
    _replyAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildGroupList(),
            AnimatedDividerCard(
              onArrowTap: widget.onToggleTap,
              arrowAnimation: widget.arrowAnimation,
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _replyScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: state.isReplying ?? false
                      ? _replyScaleAnimation.value
                      : 1.0,
                  child: EnhancedUnifiedMessageInput(
                    chatData: widget.data,
                    onCancelReply: _cancelReply,
                  ),
                );
              },
            ),
            20.verticalSpace,
          ],
        );
      },
    );
  }

  Widget _buildGroupList() {
    return BlocSelector<ChatCubit, ChatState, List<Entry>>(
      selector: (state) {
        return state.chatEntry?.entries ?? [];
      },
      builder: (context, state) {
        final pinnedList = state
            .where((e) => (e.pinned ?? '').trim().toUpperCase() == 'Y')
            .toList();

        return ListView.builder(
          cacheExtent: 2000,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pinnedList.length,
          itemBuilder: (context, index) {
            final data = pinnedList[index];
            return GroupCardWidget(
              title: data.sender?.name,
              imageUrl: data.sender?.imageUrl,
              chatId: data.chatId ?? 0,
            );
          },
        );
      },
    );
  }
}

class ChatHeader extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ChatHeader({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final pinnedLists = context.select(
      (ChatCubit cubit) => cubit.state.chatEntry?.entries,
    );
    final pinnedList = pinnedLists
        ?.where((e) => (e.pinned ?? '').trim().toUpperCase() == 'Y')
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupCardWidget(
          title: (pinnedList?.isNotEmpty ?? false)
              ? pinnedList![0].sender?.name
              : '',
          imageUrl: (pinnedList?.isNotEmpty ?? false)
              ? pinnedList![0].sender?.imageUrl
              : '',
        ),
      ],
    );
  }
}
