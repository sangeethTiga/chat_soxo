import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/chat_profile_screen.dart';
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

  final ScrollController _messageScrollController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};

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
    _messageScrollController.dispose();
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

  // FIX: Ensure message keys are populated from chat entries
  void _ensureMessageKeysExist(List<Entry> entries) {
    log('🔧 Ensuring keys exist for ${entries.length} entries');

    for (final entry in entries) {
      final messageId = entry.id.toString();
      if (!_messageKeys.containsKey(messageId)) {
        _messageKeys[messageId] = GlobalKey();
        log('✅ Created new key for message: "$messageId"');
      }
    }

    log('📊 Total keys after ensuring: ${_messageKeys.length}');
  }

  void _scrollToPinnedMessage(Entry pinnedMessage) {
    log('🎯 Attempting to scroll to pinned message: ${pinnedMessage.id}');

    final chatCubit = context.read<ChatCubit>();

    if (chatCubit.state.isArrow) {
      log('📱 Switching from group view to chat view');
      chatCubit.arrowSelected();
      _animationController.reverse();

      Future.delayed(const Duration(milliseconds: 350), () {
        _performScroll(pinnedMessage);
      });
    } else {
      _performScroll(pinnedMessage);
    }
  }

  void _performScroll(Entry pinnedMessage) {
    final messageKey = _messageKeys[pinnedMessage.id.toString()];

    log('🔍 Looking for key: ${pinnedMessage.id.toString()}');
    log('🔍 Available keys: ${_messageKeys.keys.toList()}');
    log('🔍 Key exists: ${messageKey != null}');
    log('🔍 Key context exists: ${messageKey?.currentContext != null}');

    if (messageKey?.currentContext != null) {
      log('✅ Found message key, scrolling to message: ${pinnedMessage.id}');

      Scrollable.ensureVisible(
        messageKey!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      ).then((_) {
        _highlightMessage(pinnedMessage.id.toString());
      });
    } else {
      log(
        '❌ Message key context not available for message: ${pinnedMessage.id}',
      );

      // IMPROVED FIX: Wait for widget to build and try multiple times
      _attemptScrollWithRetry(pinnedMessage, 0);
    }
  }

  void _attemptScrollWithRetry(Entry pinnedMessage, int attempt) {
    if (attempt >= 10) {
      log('❌ Failed to scroll after 10 attempts');
      return;
    }

    // Wait for next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 100 * (attempt + 1)), () {
        final messageKey = _messageKeys[pinnedMessage.id.toString()];

        if (messageKey?.currentContext != null) {
          log(
            '✅ Found context on attempt ${attempt + 1}, scrolling to message: ${pinnedMessage.id}',
          );

          Scrollable.ensureVisible(
            messageKey!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
          ).then((_) {
            _highlightMessage(pinnedMessage.id.toString());
          });
        } else {
          log('🔄 Attempt ${attempt + 1} failed, retrying...');

          // Try scrolling to approximate position first
          if (_messageScrollController.hasClients && attempt == 2) {
            _scrollToApproximatePosition(pinnedMessage);
          }

          _attemptScrollWithRetry(pinnedMessage, attempt + 1);
        }
      });
    });
  }

  void _scrollToApproximatePosition(Entry pinnedMessage) {
    // Get all entries and find the position of the target message
    final chatState = context.read<ChatCubit>().state;
    final entries =
        chatState.chatEntry?.entries
            ?.where((e) => e.messageType != 'html')
            .toList() ??
        [];

    entries.sort((a, b) {
      final aTime = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    final targetIndex = entries.indexWhere((e) => e.id == pinnedMessage.id);

    if (targetIndex != -1 && _messageScrollController.hasClients) {
      // Estimate scroll position (each message roughly 80-120 pixels)
      final estimatedPosition = targetIndex * 100.0;
      final maxScroll = _messageScrollController.position.maxScrollExtent;
      final scrollTo = (estimatedPosition > maxScroll)
          ? maxScroll
          : estimatedPosition;

      log(
        '📍 Scrolling to estimated position: $scrollTo for index: $targetIndex',
      );

      _messageScrollController.animateTo(
        scrollTo,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _highlightMessage(String messageId) {
    log('✨ Highlighting message: $messageId');
    // Add your highlight logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithProfile(
        context,
        {},
        title: widget.data?['title'],
        image: widget.data?['image'],
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatProfileScreen(
                chatData:
                    widget.data ??
                    {
                      'title': widget.data?['title'] ?? 'Unknown',
                      'image': widget.data?['image'],
                      'chat_id': widget.data?['chat_id'],
                      'type': widget.data?['type'] ?? '',
                    },
              ),
            ),
          );
        },
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.chatEntry?.entries?.length !=
                current.chatEntry?.entries?.length,
        listener: (context, state) {
          _handleErrorMessage(context, state);

          // FIX: Ensure keys are created when chat entries are loaded
          if (state.chatEntry?.entries != null) {
            _ensureMessageKeysExist(state.chatEntry!.entries!);
          }
        },
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
                            onPinnedMessageTap: _scrollToPinnedMessage,
                          )
                        : ChatContent(
                            onPinnedMessageTap: _scrollToPinnedMessage,
                            key: const ValueKey('chat'),
                            data: widget.data,
                            onToggleTap: _handleViewToggle,
                            arrowAnimation: _arrowRotationAnimation,
                            scrollController: _messageScrollController,
                            messageKeys: _messageKeys,
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
  final Function(Entry)? onPinnedMessageTap;

  const GroupContent({
    super.key,
    required this.onToggleTap,
    required this.arrowAnimation,
    required this.contentAnimation,
    required this.data,
    this.onPinnedMessageTap,
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

  void _cancelReply() {
    context.read<ChatCubit>().cancelReply();
    _replyAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final pinnedList = state.chatEntry?.entries
            ?.where((e) => (e.pinned ?? '').trim().toUpperCase() == 'Y')
            .toList();
        return Column(
          children: [
            _buildGroupList(pinnedList ?? []),
            AnimatedDividerCard(
              count: pinnedList?.length.toString(),
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

  Widget _buildGroupList(List<Entry> pinnedEntries) {
    return ListView.builder(
      cacheExtent: 2000,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pinnedEntries.length,
      itemBuilder: (context, index) {
        final data = pinnedEntries[index];
        return GroupCardWidget(
          title: data.sender?.name,
          imageUrl: data.sender?.imageUrl,
          chatId: data.chatId ?? 0,
          onTap: () {
            log('🔥 Pinned message tapped: ${data.id} - ${data.content}');
            widget.onPinnedMessageTap?.call(data);
          },
        );
      },
    );
  }
}

class ChatContent extends StatefulWidget {
  final Map<String, dynamic>? data;
  final VoidCallback onToggleTap;
  final Animation<double> arrowAnimation;
  final ScrollController? scrollController;
  final Map<String, GlobalKey>? messageKeys;
  final Function(Entry)? onPinnedMessageTap;

  const ChatContent({
    super.key,
    this.data,
    required this.onToggleTap,
    required this.arrowAnimation,
    this.scrollController,
    this.messageKeys,
    required this.onPinnedMessageTap,
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
    log(' Started reply to message: ${message.id}');
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
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              if (pinnedEntries.isNotEmpty) ...{
                GroupCardWidget(
                  title: pinnedEntries[0].sender?.name,
                  imageUrl: pinnedEntries[0].sender?.imageUrl,
                  onTap: () {
                    widget.onPinnedMessageTap?.call(pinnedEntries[0]);
                  },
                ),
                AnimatedDividerCard(
                  count: pinnedEntries.length.toString(),
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
                  scrollController: widget.scrollController,
                  messageKeys: widget.messageKeys,
                ),
              ),

              14.verticalSpace,
              EnhancedUnifiedMessageInput(
                chatData: widget.data,
                onCancelReply: _cancelReply,
              ),
            ],
          ),
        );
      },
    );
  }
}
