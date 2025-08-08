import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_model/chat_models.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/chat/domain/repositories/chat_repositories.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  final ChatRepositories _chatRepositories;
  final ImagePicker _imagePicker = ImagePicker();

  // Store loaded media files
  final Map<String, String> _fileUrls = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, bool> _loadingFiles = {};

  ChatCubit(this._chatRepositories) : super(InitilaChatState()) {
    _initializePermissions();
  }

  // UI State Management
  Future<void> arrowSelected() async {
    emit(state.copyWith(isArrow: !state.isArrow));
  }

  void resetState() {
    emit(state.copyWith(isArrow: false));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  // Permission Management
  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.microphone.request();
      emit(
        state.copyWith(
          hasRecordingPermission: status == PermissionStatus.granted,
        ),
      );
      log(
        'Microphone permission: ${status == PermissionStatus.granted ? "GRANTED" : "DENIED"}',
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to check microphone permission: $e',
        ),
      );
      log('Permission error: $e');
    }
  }

  // Voice Recording Methods
  Future<void> startRecording() async {
    try {
      log('Starting recording...');

      if (!state.hasRecordingPermission) {
        await _initializePermissions();
        if (!state.hasRecordingPermission) {
          emit(
            state.copyWith(
              errorMessage:
                  'Microphone permission is required for voice recording',
            ),
          );
          return;
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final recordingPath = '${directory.path}/$fileName';

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: recordingPath,
        );

        emit(
          state.copyWith(
            isRecording: true,
            recordingPath: recordingPath,
            recordingDuration: Duration.zero,
            errorMessage: null,
          ),
        );

        _startRecordingTimer();
        log('Recording started successfully at: $recordingPath');
      } else {
        emit(state.copyWith(errorMessage: 'Microphone permission denied'));
      }
    } catch (e) {
      log('Error starting recording: $e');
      emit(state.copyWith(errorMessage: 'Failed to start recording: $e'));
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRecording) {
        final newDuration = Duration(seconds: timer.tick);
        emit(state.copyWith(recordingDuration: newDuration));
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> stopRecordingAndSend(AddChatEntryRequest req) async {
    try {
      if (!state.isRecording) return;

      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();

      if (path != null && state.recordingPath != null) {
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          final fileSize = await file.length();

          if (fileSize > 0) {
            // Create and send voice message through createChat
            await createChat(
              AddChatEntryRequest(
                chatId: req.chatId, // Use current chat ID
                senderId: 45,
                type: 'N',
                typeValue: 0,
                messageType: 'voice',
                content: 'Voice message',
                source: 'Mobile',
              ),
              files: [file],
            );

            // Reset recording state
            emit(
              state.copyWith(
                isRecording: false,
                recordingDuration: Duration.zero,
                recordingPath: null,
                errorMessage: null,
              ),
            );
          } else {
            _handleRecordingError('Recording failed - file is empty');
          }
        } else {
          _handleRecordingError('Recording failed - file not found');
        }
      } else {
        _handleRecordingError('Recording failed - no file path');
      }
    } catch (e) {
      log('Error stopping recording: $e');
      _handleRecordingError('Failed to stop recording: $e');
    }
  }

  void _handleRecordingError(String error) {
    emit(
      state.copyWith(
        isRecording: false,
        recordingDuration: Duration.zero,
        recordingPath: null,
        errorMessage: error,
      ),
    );
  }

  Future<void> cancelRecording() async {
    try {
      if (!state.isRecording) return;

      _recordingTimer?.cancel();
      await _audioRecorder.stop();

      if (state.recordingPath != null) {
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          await file.delete();
          log('Recording file deleted: ${state.recordingPath}');
        }
      }

      emit(
        state.copyWith(
          isRecording: false,
          recordingDuration: Duration.zero,
          recordingPath: null,
          errorMessage: null,
        ),
      );
    } catch (e) {
      log('Error cancelling recording: $e');
      _handleRecordingError('Failed to cancel recording: $e');
    }
  }

  // Message Methods
  void sendTextMessage(String message, AddChatEntryRequest req) {
    if (message.trim().isEmpty) return;

    final request = AddChatEntryRequest(
      chatId: req.chatId,
      senderId: 45,
      type: 'N',
      typeValue: 0,
      messageType: 'text',
      content: message.trim(),
      source: 'Mobile',
    );

    createChat(request);
  }

  // Chat API Methods
  Future<void> getChatList() async {
    emit(state.copyWith(isChat: ApiFetchStatus.loading));

    try {
      final res = await _chatRepositories.chatList();
      if (res.data != null) {
        emit(
          state.copyWith(
            chatList: res.data,
            isChat: ApiFetchStatus.success,
            allChats: res.data,
            selectedTab: 'all',
          ),
        );
      } else {
        emit(state.copyWith(isChat: ApiFetchStatus.failed, chatList: []));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isChat: ApiFetchStatus.failed,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getChatEntry({int? chatId, int? userId}) async {
    emit(state.copyWith(isChatEntry: ApiFetchStatus.loading));

    try {
      final res = await _chatRepositories.chatEntry(chatId ?? 0, userId ?? 0);
      if (res.data != null) {
        emit(
          state.copyWith(
            chatEntry: res.data,
            isChatEntry: ApiFetchStatus.success,
          ),
        );

        // Load media files for this chat entry
        if (res.data?.entries != null) {
          _loadMediaFilesForEntries(res.data!.entries!);
        }
      } else {
        emit(
          state.copyWith(isChatEntry: ApiFetchStatus.success, chatEntry: null),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isChatEntry: ApiFetchStatus.failed,
          errorMessage: e.toString(),
        ),
      );
      log('Error getting chat entry: $e');
    }
  }

  Future<void> createChat(
    AddChatEntryRequest request, {
    List<File>? files,
  }) async {
    try {
      final messageText = request.content?.trim();
      if (messageText == null ||
          messageText.isEmpty && files?.isEmpty != false) {
        return;
      }

      final filesToSend = files ?? state.selectedFiles ?? [];

      // Create optimistic message
      final tempMessage = Entry(
        content: request.content ?? "File attachment",
        messageType: request.messageType,
        senderId: request.senderId,
        type: request.type,
        typeValue: request.typeValue,
        createdAt: DateTime.now().toIso8601String(),
        chatId: request.chatId,
      );

      // Add optimistic message to state
      final currentEntries = state.chatEntry?.entries ?? <Entry>[];
      final updatedEntries = List<Entry>.from(currentEntries)..add(tempMessage);

      emit(
        state.copyWith(
          chatEntry:
              state.chatEntry?.copyWith(entries: updatedEntries) ??
              ChatEntryResponse(entries: updatedEntries),
        ),
      );

      // Make API call
      final res = await _chatRepositories.addChatEntry(
        req: request,
        files: filesToSend,
      );

      if (res.data != null) {
        // Replace optimistic message with server response
        final serverEntry = Entry(
          id: res.data!.id,
          content: res.data!.content,
          messageType: res.data!.messageType,
          senderId: res.data!.senderId,
          type: res.data!.type,
          typeValue: res.data!.typeValue,
          createdAt: res.data!.createdAt?.toString(),
          chatId: res.data!.chatId,
          thread: res.data?.thread,
        );

        final finalEntries = updatedEntries.map((entry) {
          return entry.id == tempMessage.id ? serverEntry : entry;
        }).toList();

        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: finalEntries),
            isChatEntry: ApiFetchStatus.success,
            selectedFiles: [], // Clear selected files after sending
          ),
        );
      } else {
        // Remove failed message
        final failedEntries = updatedEntries
            .where((entry) => entry.id != tempMessage.id)
            .toList();

        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: failedEntries),
            isChatEntry: ApiFetchStatus.failed,
            errorMessage: 'Failed to send message',
          ),
        );
      }
    } catch (e) {
      log('Error creating chat entry: $e');
      emit(
        state.copyWith(
          isChatEntry: ApiFetchStatus.failed,
          errorMessage: 'Error: ${e.toString()}',
        ),
      );
    }
  }

  // File Selection Methods
  Future<void> selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true,
      );

      if (result != null) {
        final files = result.paths.map((path) => File(path!)).toList();
        final currentFiles = state.selectedFiles ?? [];
        final updatedFiles = [...currentFiles, ...files];

        emit(state.copyWith(selectedFiles: updatedFiles));
        log('Selected ${files.length} files');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error selecting files: $e'));
      log('Error selecting files: $e');
    }
  }

  Future<void> selectImageFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _addSelectedFile(File(image.path));
        log('Selected image from gallery: ${image.path}');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error selecting image: $e'));
    }
  }

  Future<void> selectImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _addSelectedFile(File(image.path));
        log('Captured image from camera: ${image.path}');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error capturing image: $e'));
    }
  }

  void _addSelectedFile(File file) {
    final currentFiles = state.selectedFiles ?? [];
    final updatedFiles = [...currentFiles, file];
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  void removeSelectedFile(int index) {
    if (state.selectedFiles != null && index < state.selectedFiles!.length) {
      final updatedFiles = List<File>.from(state.selectedFiles!);
      updatedFiles.removeAt(index);
      emit(state.copyWith(selectedFiles: updatedFiles));
      log('Removed file at index $index');
    }
  }

  void clearSelectedFiles() {
    emit(state.copyWith(selectedFiles: []));
    log('Cleared all selected files');
  }

  // Media Loading Methods
  Future<void> _loadMediaFilesForEntries(List<Entry> entries) async {
    for (final entry in entries) {
      if (entry.chatMedias != null && entry.chatMedias!.isNotEmpty) {
        for (final media in entry.chatMedias!) {
          await _loadMediaFile(media);
        }
      }
    }
  }

  Future<void> _loadMediaFile(ChatMedias media) async {
    if (media.id == null || media.mediaUrl == null) return;

    final String mediaId = media.id.toString();

    if (_fileUrls.containsKey(mediaId)) return; // Already loaded

    _loadingFiles[mediaId] = true;

    try {
      final fileData = await _chatRepositories.getFileFromApi(
        media.mediaUrl ?? '',
      );
      _fileUrls[mediaId] = fileData['data'];
      _fileTypes[mediaId] = fileData['type'];

      log('Loaded media file: $mediaId, type: ${fileData['type']}');
    } catch (e) {
      log('Error loading file $mediaId: $e');
    } finally {
      _loadingFiles[mediaId] = false;
    }
  }

  // Getters for UI
  String? getFileUrl(String mediaId) => _fileUrls[mediaId];
  String? getFileType(String mediaId) => _fileTypes[mediaId];
  bool isFileLoading(String mediaId) => _loadingFiles[mediaId] ?? false;

  // Tab Management
  Future<void> selectedTab(String value) async {
    emit(state.copyWith(selectedTab: value));
    await Future.delayed(const Duration(milliseconds: 100));
    _filterChatList(value);
  }

  void _filterChatList(String selectedTab) {
    if (state.allChats == null) return;

    List<ChatListResponse> filteredChats;
    switch (selectedTab) {
      case 'all':
        filteredChats = List.from(state.allChats!);
        break;
      case 'group':
        filteredChats = state.allChats!
            .where((chat) => chat.type?.toLowerCase() == 'group')
            .toList();
        break;
      case 'personal':
        filteredChats = state.allChats!
            .where((chat) => chat.type?.toLowerCase() == 'personal')
            .toList();
        break;
      case 'broadcast':
        filteredChats = state.allChats!
            .where((chat) => chat.type?.toLowerCase() == 'broadcast')
            .toList();
        break;
      default:
        filteredChats = List.from(state.allChats!);
    }

    emit(state.copyWith(chatList: filteredChats, selectedTab: selectedTab));
  }

  // Utility Methods
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> initStateClear() async {
    emit(state.copyWith(isArrow: false));
  }

  @override
  Future<void> close() {
    log('Closing ChatCubit...');
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }
}
