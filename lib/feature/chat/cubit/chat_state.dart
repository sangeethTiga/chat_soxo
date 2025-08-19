part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final bool isArrow;
  final bool isRecording;
  final Duration recordingDuration;
  final String? recordingPath;
  final bool hasRecordingPermission;
  final String? errorMessage;
  final List<ChatListResponse>? chatList;
  final List<ChatListResponse>? allChats;

  final ApiFetchStatus? isChat;
  final ChatEntryResponse? chatEntry;
  final ApiFetchStatus? isChatEntry;
  final String? selectedTab;
  final List<File>? selectedFiles;
  final bool isUploadingFiles;
  final double uploadProgress;
  final Map<String, String>? fileUrls;
  final Map<String, String>? fileTypes;
  final Map<String, dynamic>? viewingFile;
  final bool? isLoadingMedia;
  final Entry? replyingTo;
  final bool? isReplying;
  final String? isPinned;
  final String? highlightedMessageId; // Message currently highlighted
  final String? scrollToMessageId; // Message to scroll to
  final Map<String, dynamic>? replyNotification; // Temporary reply notification
  final Map<String, Entry>? replyRelationships; // Cache of reply relationships
  final Set<String>? activeReplies;
  final String? selectedReplyMessageId;
  final Entry? selectedReplyMessage;
  const ChatState({
    this.isArrow = false,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.recordingPath,
    this.hasRecordingPermission = false,
    this.errorMessage,
    this.chatList,
    this.isChat = ApiFetchStatus.idle,
    this.chatEntry,
    this.isChatEntry = ApiFetchStatus.idle,
    this.selectedTab,
    this.allChats,
    this.selectedFiles,
    this.isUploadingFiles = false,
    this.uploadProgress = 0.0,
    this.fileUrls,
    this.fileTypes,
    this.viewingFile,
    this.isLoadingMedia,
    this.isReplying,
    this.replyingTo,
    this.isPinned,
    this.highlightedMessageId,
    this.scrollToMessageId,
    this.replyNotification,
    this.replyRelationships,
    this.activeReplies,
    this.selectedReplyMessageId, // ✅ NEW
    this.selectedReplyMessage,
  });

  ChatState copyWith({
    bool? isArrow,
    bool? isRecording,
    Duration? recordingDuration,
    String? recordingPath,
    bool? hasRecordingPermission,
    String? errorMessage,
    List<ChatListResponse>? chatList,
    ApiFetchStatus? isChat,
    ChatEntryResponse? chatEntry,
    ApiFetchStatus? isChatEntry,
    String? selectedTab,
    List<ChatListResponse>? allChats,
    List<File>? selectedFiles,
    bool? isUploadingFiles,
    double? uploadProgress,
    Map<String, String>? fileUrls,
    Map<String, String>? fileTypes,
    Map<String, dynamic>? viewingFile,
    bool? isLoadingMedia,
    List<Entry>? instantMessages,
    Entry? replyingTo,
    bool? isReplying,
    String? isPinned,
    String? highlightedMessageId,
    String? scrollToMessageId,
    Map<String, dynamic>? replyNotification,
    Map<String, Entry>? replyRelationships,
    Set<String>? activeReplies,
    String? selectedReplyMessageId, // ✅ NEW
    Entry? selectedReplyMessage,
  }) {
    return ChatState(
      isArrow: isArrow ?? this.isArrow,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingPath: recordingPath ?? this.recordingPath,
      hasRecordingPermission:
          hasRecordingPermission ?? this.hasRecordingPermission,
      errorMessage: errorMessage ?? this.errorMessage,
      chatList: chatList ?? this.chatList,
      isChat: isChat ?? this.isChat,
      chatEntry: chatEntry ?? this.chatEntry,
      isChatEntry: isChatEntry ?? this.isChatEntry,
      selectedTab: selectedTab ?? this.selectedTab,
      allChats: allChats ?? this.allChats,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      isUploadingFiles: isUploadingFiles ?? this.isUploadingFiles,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      fileUrls: fileUrls ?? this.fileUrls,
      fileTypes: fileTypes ?? this.fileTypes,
      viewingFile: viewingFile ?? this.viewingFile,
      isLoadingMedia: isLoadingMedia ?? this.isLoadingMedia,
      replyingTo: replyingTo ?? this.replyingTo,
      isReplying: isReplying ?? this.isReplying,
      isPinned: isPinned ?? this.isPinned,

      highlightedMessageId: highlightedMessageId ?? this.highlightedMessageId,
      scrollToMessageId: scrollToMessageId ?? this.scrollToMessageId,
      replyNotification: replyNotification ?? this.replyNotification,
      replyRelationships: replyRelationships ?? this.replyRelationships,
      activeReplies: activeReplies ?? this.activeReplies,

      selectedReplyMessageId:
          selectedReplyMessageId ?? this.selectedReplyMessageId, // ✅ NEW
      selectedReplyMessage:
          selectedReplyMessage ?? this.selectedReplyMessage, // ✅ NEW
    );
  }

  @override
  List<Object?> get props => [
    isArrow,
    isRecording,
    recordingDuration,
    recordingPath,
    hasRecordingPermission,
    errorMessage,
    chatList,
    isChat,
    chatEntry,
    isChatEntry,
    selectedTab,
    allChats,
    selectedFiles,
    isUploadingFiles,
    uploadProgress,
    fileUrls,
    fileTypes,
    viewingFile,
    isLoadingMedia,
    isReplying,
    replyingTo,
    isPinned,
    highlightedMessageId,
    scrollToMessageId,
    replyNotification,
    replyRelationships,
    activeReplies,
    selectedReplyMessageId, // ✅ NEW
    selectedReplyMessage,
  ];
}

class InitialChatState extends ChatState {
  InitialChatState()
    : super(
        isChatEntry: ApiFetchStatus.idle,
        isChat: ApiFetchStatus.idle,
        chatEntry: null,
        chatList: null,
        allChats: null,
        selectedTab: 'all',
        selectedFiles: null,
        isRecording: false,
        recordingDuration: Duration.zero,
        recordingPath: null,
        hasRecordingPermission: false,
        errorMessage: null,
        fileUrls: {},
        fileTypes: {},
        isArrow: false,
      );
}

extension ChatStateReplyHelpers on ChatState {
  // Check if a message is highlighted
  bool isMessageHighlighted(String messageId) {
    return highlightedMessageId == messageId;
  }

  // Check if should scroll to message
  bool shouldScrollToMessage(String messageId) {
    return scrollToMessageId == messageId;
  }

  Map<String, dynamic>? getActiveReplyNotification() {
    if (replyNotification == null) return null;

    final timestamp = replyNotification!['timestamp'] as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final isExpired = (now - timestamp) > 3000; // 3 seconds

    return isExpired ? null : replyNotification;
  }

  bool isReplyMessage(Entry entry) {
    return entry.type == 'CR' ||
        (entry.otherDetails1?.isNotEmpty == true &&
            entry.otherDetails1!.contains('ReplayChatEntryId'));
  }

  Entry? getOriginalMessageForReply(Entry replyEntry) {
    if (!isReplyMessage(replyEntry)) return null;

    try {
      if (replyEntry.otherDetails1?.isNotEmpty == true) {
        final decoded = jsonDecode(replyEntry.otherDetails1!);
        if (decoded is List && decoded.isNotEmpty) {
          final replyInfo = decoded[0];
          if (replyInfo is Map<String, dynamic>) {
            final originalId =
                replyInfo['ReplayChatEntryId']?.toString() ??
                replyInfo['InitialChatEntryId']?.toString();

            if (originalId != null) {
              return chatEntry?.entries?.firstWhere(
                (e) => e.id.toString() == originalId,
                orElse: () => throw StateError('Not found'),
              );
            }
          }
        }
      }
    } catch (e) {
      // Return null if not found
    }

    return null;
  }

  // Get all replies for a message
  List<Entry> getRepliesForMessage(String messageId) {
    if (chatEntry?.entries == null) return [];

    return chatEntry!.entries!.where((entry) {
      if (!isReplyMessage(entry)) return false;

      try {
        if (entry.otherDetails1?.isNotEmpty == true) {
          final decoded = jsonDecode(entry.otherDetails1!);
          if (decoded is List && decoded.isNotEmpty) {
            final replyInfo = decoded[0];
            if (replyInfo is Map<String, dynamic>) {
              final replyToId =
                  replyInfo['ReplayChatEntryId']?.toString() ??
                  replyInfo['InitialChatEntryId']?.toString();
              return replyToId == messageId;
            }
          }
        }
      } catch (e) {
        // Ignore parse errors
      }

      return false;
    }).toList();
  }
}
