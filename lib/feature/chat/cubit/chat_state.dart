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
    List<File>? selectedFiles,
    bool? isUploadingFiles,
    double? uploadProgress,
    Map<String, String>? fileUrls,
    Map<String, String>? fileTypes,
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
  ];
}

class InitilaChatState extends ChatState {}
