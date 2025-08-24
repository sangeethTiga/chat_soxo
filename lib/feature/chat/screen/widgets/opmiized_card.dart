import 'dart:async';
import 'dart:convert';
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

// Fixed OptimizedChatMessagesLists with proper key management
class OptimizedChatMessagesLists extends StatefulWidget {
  final Function(Entry)? onReplyMessage;
  final Map<String, dynamic>? chatData;
  final Entry? currentReplyingTo;
  final bool isReplying;
  final ScrollController? scrollController;
  final Map<String, GlobalKey>? messageKeys;

  const OptimizedChatMessagesLists({
    super.key,
    this.onReplyMessage,
    this.currentReplyingTo,
    this.isReplying = false,
    this.chatData,
    this.scrollController,
    this.messageKeys,
  });

  @override
  State<OptimizedChatMessagesLists> createState() =>
      _OptimizedChatMessagesListsState();
}

class _OptimizedChatMessagesListsState
    extends State<OptimizedChatMessagesLists> {
  late ScrollController _scrollController;
  List<Entry>? _previousEntries;
  int _previousEntriesHash = 0;
  late Map<String, GlobalKey> _messageKeys;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _messageKeys = widget.messageKeys ?? {};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _togglePin(Entry message) {
    context.read<ChatCubit>().pinnedMessage(
      message: message,
      chatEntryId: message.id.toString(),
      pinned: 'Y',
    );
  }

  bool _isPinned(Entry message) {
    return message.pinned == 'Y';
  }

  Entry? _getReplyMessage(Entry message, List<Entry> allEntries) {
    final String? detailsStr = message.otherDetails1;
    if (detailsStr != null && detailsStr.isNotEmpty) {
      try {
        List<dynamic> detailsList = jsonDecode(detailsStr);
        if (detailsList.isNotEmpty) {
          var details = detailsList[0];
          final String? replayChatEntryId = details["ReplayChatEntryId"]
              ?.toString();

          if (replayChatEntryId != null && replayChatEntryId.isNotEmpty) {
            try {
              final originalMessage = allEntries.firstWhere(
                (e) => e.id.toString() == replayChatEntryId,
              );
              return originalMessage;
            } catch (e) {
              log("❌ Original message not found for ID: $replayChatEntryId");
            }
          }
        }
      } catch (e) {
        log("❌ Could not find original message: $e");
      }
    }
    return null;
  }

  void _startReply(Entry message) {
    widget.onReplyMessage?.call(message);
    _scrollToBottom();
  }

  void _scrollToReply(Entry message, List<Entry> allEntries) {
    final replyMessage = _getReplyMessage(message, allEntries);
    if (replyMessage != null) {
      final key = _messageKeys[replyMessage.id.toString()];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _checkAndScrollToBottom(List<Entry> currentEntries) {
    final currentHash = Object.hashAll(currentEntries.map((e) => e.id));

    if (_previousEntries != null &&
        (currentEntries.length > _previousEntries!.length ||
            currentHash != _previousEntriesHash)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else if (_previousEntries == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom(animate: false);
      });
    }

    _previousEntries = List.from(currentEntries);
    _previousEntriesHash = currentHash;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) {
        final prevCount = previous.chatEntry?.entries?.length ?? 0;
        final currCount = current.chatEntry?.entries?.length ?? 0;
        final statusChanged = previous.isChatEntry != current.isChatEntry;
        final entriesChanged = prevCount != currCount;
        final hashChanged =
            previous.chatEntry?.entries?.hashCode !=
            current.chatEntry?.entries?.hashCode;
        final replyStateChanged =
            previous.isReplying != current.isReplying ||
            previous.replyingTo?.id != current.replyingTo?.id;

        return statusChanged ||
            entriesChanged ||
            hashChanged ||
            replyStateChanged;
      },
      listener: (context, state) {
        if (state.chatEntry?.entries != null) {
          _checkAndScrollToBottom(state.chatEntry!.entries!);
        }
      },
      buildWhen: (previous, current) {
        final statusChanged = previous.isChatEntry != current.isChatEntry;
        final entriesCountChanged =
            previous.chatEntry?.entries?.length !=
            current.chatEntry?.entries?.length;
        final entriesHashChanged =
            previous.chatEntry?.entries?.hashCode !=
            current.chatEntry?.entries?.hashCode;
        final errorChanged = previous.errorMessage != current.errorMessage;
        final replyStateChanged =
            previous.isReplying != current.isReplying ||
            previous.replyingTo?.id != current.replyingTo?.id;

        return statusChanged ||
            entriesCountChanged ||
            entriesHashChanged ||
            errorChanged ||
            replyStateChanged;
      },
      builder: (context, state) {
        if (state.errorMessage != null &&
            state.isChatEntry == ApiFetchStatus.failed) {
          return _buildErrorState(state.errorMessage!);
        }

        if (state.isChatEntry == ApiFetchStatus.loading) {
          return _buildShimmerList();
        }

        if (state.chatEntry?.entries?.isEmpty ?? true) {
          return const AnimatedEmptyChatWidget();
        }

        final entries = state.chatEntry!.entries!;
        return _buildMessagesList(entries, state);
      },
    );
  }

  Widget _buildMessagesList(List<Entry> entries, ChatState chatState) {
    final pinnedList = entries.where((e) => e.messageType != 'html').toList();

    pinnedList.sort((a, b) {
      final aTime = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
      final bTime = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    _ensureKeysExist(pinnedList);

    log('📋 Total message keys available: ${_messageKeys.keys.length}');
    log('📋 Message IDs: ${_messageKeys.keys.toList()}');

    return FutureBuilder(
      future: AuthUtils.instance.readUserData(),
      builder: (context, asyncSnapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(Duration(milliseconds: 45));
          if (_scrollController.hasClients && pinnedList.isNotEmpty) {
            _scrollToBottom(animate: false);
          }
        });

        if (!asyncSnapshot.hasData) {
          return _buildShimmerList();
        }

        final int userId =
            int.tryParse(
              asyncSnapshot.data?.result?.userId.toString() ?? '0',
            ) ??
            0;

        return ListView.builder(
          // FIXED: Much larger cache extent to keep more widgets in memory
          cacheExtent: 10000,
          // Keep widgets alive automatically
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
          // Disable item extent for better caching
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          itemCount: pinnedList.length,
          itemBuilder: (context, index) {
            final messageData = pinnedList[index];
            final messageId = messageData.id.toString();

            // CRITICAL FIX: Use existing key instead of creating new one
            final messageKey = _messageKeys[messageId]!;

            log(
              '🎯 Building message $messageId with key: ${messageKey.hashCode}',
            );

            final originalMessage = _getReplyMessage(messageData, pinnedList);
            final isBeingRepliedTo =
                (chatState.isReplying ?? false) &&
                chatState.replyingTo?.id == messageData.id;

            return ChatBubbleMessage(
              key: messageKey, // Use the pre-created key
              type: messageData.messageType,
              message: messageData.content ?? '',
              timestamp: getFormattedDate(messageData.createdAt ?? ''),
              isSent: messageData.senderId == userId,
              chatMedias: messageData.chatMedias,
              messageData: messageData,
              replyToMessage: originalMessage,
              isPinned: _isPinned(messageData),
              chatEntryId: messageData.id.toString(),
              chatId: messageData.chatId.toString(),
              isBeingRepliedTo: isBeingRepliedTo,
              scrollController: _scrollController,
              messageKeys: _messageKeys,
              onReply: () => _startReply(messageData),
              onPin: () => _togglePin(messageData),
              onScrollToReply: () => _scrollToReply(messageData, pinnedList),
            );
          },
        );
      },
    );
  }

  void _ensureKeysExist(List<Entry> entries) {
    log('🔧 Ensuring keys exist for ${entries.length} entries');
    log('🔧 Current keys count: ${_messageKeys.length}');

    for (final entry in entries) {
      final messageId = entry.id.toString();

      log(
        '🔑 Processing entry ID: ${entry.id} (type: ${entry.id.runtimeType}) -> "$messageId"',
      );

      if (!_messageKeys.containsKey(messageId)) {
        _messageKeys[messageId] = GlobalKey();
        log('✅ Created new key for message: "$messageId"');
      } else {
        log('♻️ Key already exists for message: "$messageId"');
      }
    }

    log('📊 Total keys after ensuring: ${_messageKeys.length}');
    log('📊 Final key list: ${_messageKeys.keys.toList()}');
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error loading messages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatCubit>().refreshChatEntry();
            },
            child: Text('Retry'),
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
}
