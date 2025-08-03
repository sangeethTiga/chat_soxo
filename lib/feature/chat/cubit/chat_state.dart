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
  final ApiFetchStatus? isChat;
  final List<ChatEntryResponse>? chatEntry;
  final ApiFetchStatus? isChatEntry;

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
    List<ChatEntryResponse>? chatEntry,
    ApiFetchStatus? isChatEntry,
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
  ];
}

class InitilaChatState extends ChatState {}
