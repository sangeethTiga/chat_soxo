part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final bool isArrow;
  final bool isRecording;
  final Duration recordingDuration;
  final String? recordingPath;
  final bool hasRecordingPermission;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final List<ChatListResponse>? chatList;
  final List<ChatListResponse>? allChats;

  final ApiFetchStatus? isChat;
  final ChatEntryResponse? chatEntry;
  final ApiFetchStatus? isChatEntry;
  final String? selectedTab;

  const ChatState({
    this.isArrow = false,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.recordingPath,
    this.hasRecordingPermission = false,
    this.messages = const [],
    this.errorMessage,
    this.chatList,
    this.isChat = ApiFetchStatus.idle,
    this.chatEntry,
    this.isChatEntry = ApiFetchStatus.idle,
    this.selectedTab,
    this.allChats,
  });

  ChatState copyWith({
    bool? isArrow,
    bool? isRecording,
    Duration? recordingDuration,
    String? recordingPath,
    bool? hasRecordingPermission,
    List<ChatMessage>? messages,
    String? errorMessage,
    List<ChatListResponse>? chatList,
    ApiFetchStatus? isChat,
    ChatEntryResponse? chatEntry,
    ApiFetchStatus? isChatEntry,
    String? selectedTab,
    List<ChatListResponse>? allChats,
  }) {
    return ChatState(
      isArrow: isArrow ?? this.isArrow,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      recordingPath: recordingPath ?? this.recordingPath,
      hasRecordingPermission:
          hasRecordingPermission ?? this.hasRecordingPermission,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
      chatList: chatList ?? this.chatList,
      isChat: isChat ?? this.isChat,
      chatEntry: chatEntry ?? this.chatEntry,
      isChatEntry: isChatEntry ?? this.isChatEntry,
      selectedTab: selectedTab ?? this.selectedTab,
      allChats: allChats ?? this.allChats,
    );
  }

  @override
  List<Object?> get props => [
    isArrow,
    isRecording,
    recordingDuration,
    recordingPath,
    hasRecordingPermission,
    messages,
    errorMessage,
    chatList,
    isChat,
    chatEntry,
    isChatEntry,
    selectedTab,
    allChats,
  ];
}

class InitilaChatState extends ChatState {}
