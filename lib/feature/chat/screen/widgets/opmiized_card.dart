import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_bubble_widget.dart';
import 'package:soxo_chat/shared/animation/empty_chat.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/app/list/helper.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/shimmer/shimmer_category.dart';

class OptimizedChatMessagesLists extends StatefulWidget {
  const OptimizedChatMessagesLists({super.key});

  @override
  State<OptimizedChatMessagesLists> createState() =>
      _OptimizedChatMessagesListsState();
}

class _OptimizedChatMessagesListsState
    extends State<OptimizedChatMessagesLists> {
  late ScrollController _scrollController;
  List<Entry>? _previousEntries;
  bool _hasScrolledToBottomOnce = false;
  final bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    if (!_scrollController.hasClients) return;

    // Use a more reliable method for scrolling to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          if (animate) {
            _scrollController.animateTo(
              maxExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(maxExtent);
          }
          log('📍 Scrolled to bottom: $maxExtent');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    log('🏗️ OptimizedChatMessagesList build() called');

    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        final prevCount = previous.chatEntry?.entries?.length ?? 0;
        final currCount = current.chatEntry?.entries?.length ?? 0;
        final statusChanged = previous.isChatEntry != current.isChatEntry;
        final entriesChanged = prevCount != currCount;

        return statusChanged || entriesChanged;
      },
      listener: (context, state) {
        log(
          '🎧 Listener triggered: Entries = ${state.chatEntry?.entries?.length ?? 0}',
        );

        // Handle new messages - scroll to bottom
        if (state.chatEntry?.entries?.isNotEmpty == true) {
          final currentEntries = state.chatEntry!.entries!;
          final currentCount = currentEntries.length;
          final previousCount = _previousEntries?.length ?? 0;

          if (currentCount > previousCount) {
            log('📝 New message detected, scrolling to bottom');
            _scrollToBottom(animate: !_isInitialLoad);
          }

          _previousEntries = currentEntries.toList();
        }

        if (state.errorMessage != null) {
          log('❌ Error in state: ${state.errorMessage}');
        }
      },
      buildWhen: (previous, current) {
        final statusChanged = previous.isChatEntry != current.isChatEntry;
        final entriesCountChanged =
            previous.chatEntry?.entries?.length !=
            current.chatEntry?.entries?.length;
        final errorChanged = previous.errorMessage != current.errorMessage;

        return statusChanged || entriesCountChanged || errorChanged;
      },
      builder: (context, state) {
        log('🏗️ Building with status: ${state.isChatEntry}');
        log('📊 Entries count: ${state.chatEntry?.entries?.length ?? 0}');

        if (state.errorMessage != null &&
            state.isChatEntry == ApiFetchStatus.failed) {
          return _buildErrorState(state.errorMessage!);
        }

        if (state.isChatEntry == ApiFetchStatus.loading) {
          log('📱 Showing shimmer loading state');
          return _buildShimmerList();
        }

        if (state.chatEntry?.entries?.isEmpty ?? true) {
          log('📱 Showing empty state');
          return const AnimatedEmptyChatWidget();
        }

        final entries = state.chatEntry!.entries!;
        log('📱 Showing messages list with ${entries.length} entries');

        return _buildMessagesList(entries);
      },
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading messages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatCubit>().refreshChatEntry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      itemCount: 6,
      itemBuilder: (context, index) =>
          ChatMessageShimmer(isSent: index % 2 == 0),
    );
  }

  Widget _buildMessagesList(List<Entry> entries) {
    final pinnedList = entries.where((e) => e.messageType != 'html').toList();

    pinnedList.sort((a, b) {
      final aTime = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    log('📱 Building ListView with ${pinnedList.length} filtered messages');

    return FutureBuilder(
      future: AuthUtils.instance.readUserData(),
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) {
          return _buildShimmerList();
        }

        final int userId =
            int.tryParse(
              asyncSnapshot.data?.result?.userId.toString() ?? '0',
            ) ??
            0;

        // ✅ KEY FIX: Ensure scroll to bottom happens after ListView is fully built
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _scrollController.hasClients) {
            _scrollToBottom(animate: false);
            // Double check with another delay
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted && _scrollController.hasClients) {
                _scrollToBottom(animate: false);
                _hasScrolledToBottomOnce = true;
              }
            });
          }
        });

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Optional: Handle scroll notifications if needed
            return false;
          },
          child: ListView.builder(
            cacheExtent: 2000,
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: pinnedList.length,
            physics: const ClampingScrollPhysics(), // Better scroll behavior
            itemBuilder: (context, index) {
              final messageData = pinnedList[index];
              final messageKey = ValueKey(
                'message_${messageData.id}_${messageData.createdAt}',
              );

              return Padding(
                key: messageKey,
                padding: EdgeInsets.only(top: 15.h),
                child: ChatBubbleMessage(
                  type: messageData.messageType,
                  message: messageData.content ?? '',
                  timestamp: getFormattedDate(messageData.createdAt ?? ''),
                  isSent: messageData.senderId == userId,
                  chatMedias: messageData.chatMedias,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AlternativeChatMessagesLists extends StatefulWidget {
  const AlternativeChatMessagesLists({super.key});

  @override
  State<AlternativeChatMessagesLists> createState() =>
      _AlternativeChatMessagesListsState();
}

class _AlternativeChatMessagesListsState
    extends State<AlternativeChatMessagesLists> {
  late ScrollController _scrollController;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state.isChatEntry == ApiFetchStatus.loading) {
          return _buildShimmerList();
        }

        if (state.chatEntry?.entries?.isEmpty ?? true) {
          return const AnimatedEmptyChatWidget();
        }

        final entries = state.chatEntry!.entries!
            .where((e) => e.messageType != 'html')
            .toList();

        // Sort messages
        entries.sort((a, b) {
          final aTime = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
          return aTime.compareTo(bTime);
        });

        return NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            // When the list metrics change (items added), scroll to bottom
            if (!_hasScrolledToBottom && entries.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom(animate: false);
                _hasScrolledToBottom = true;
              });
            }
            return false;
          },
          child: FutureBuilder(
            future: AuthUtils.instance.readUserData(),
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.hasData) {
                return _buildShimmerList();
              }

              final int userId =
                  int.tryParse(
                    asyncSnapshot.data?.result?.userId.toString() ?? '0',
                  ) ??
                  0;

              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final messageData = entries[index];

                  // Schedule scroll on last item render
                  if (index == entries.length - 1 && !_hasScrolledToBottom) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) {
                          _scrollToBottom(animate: false);
                          _hasScrolledToBottom = true;
                        }
                      });
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 15.h),
                    child: ChatBubbleMessage(
                      type: messageData.messageType,
                      message: messageData.content ?? '',
                      timestamp: getFormattedDate(messageData.createdAt ?? ''),
                      isSent: messageData.senderId == userId,
                      chatMedias: messageData.chatMedias,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      itemCount: 6,
      itemBuilder: (context, index) =>
          ChatMessageShimmer(isSent: index % 2 == 0),
    );
  }
}
