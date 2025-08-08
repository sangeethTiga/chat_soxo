import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final Map<String, String> _fileUrls = {};
  final Map<String, String> _fileTypes = {};
  final Map<String, bool> _loadingFiles = {};
  final Map<String, DateTime> _fileCacheTimestamps = {};
  final Set<String> _failedLoads = {};

  Timer? _batchUpdateTimer;
  bool _hasPendingUpdates = false;
  bool _isDisposed = false;

  static const Duration _cacheExpiration = Duration(hours: 2);
  static const Duration _batchDelay = Duration(milliseconds: 16);

  ChatCubit(this._chatRepositories) : super(InitilaChatState()) {
    _initializePermissions();
  }

  void _emitInstant(ChatState newState) {
    if (!_isDisposed) {
      emit(newState);
    }
  }

  void _scheduleMediaUpdate() {
    if (_isDisposed) return;

    _hasPendingUpdates = true;
    _batchUpdateTimer?.cancel();

    _batchUpdateTimer = Timer(_batchDelay, () {
      if (_hasPendingUpdates && !_isDisposed) {
        _emitInstant(
          state.copyWith(
            fileUrls: Map<String, String>.from(_fileUrls),
            fileTypes: Map<String, String>.from(_fileTypes),
          ),
        );
        _hasPendingUpdates = false;
      }
    });
  }

  Future<void> arrowSelected() async {
    _emitInstant(state.copyWith(isArrow: !state.isArrow));
  }

  void resetState() {
    _emitInstant(state.copyWith(isArrow: false));
  }

  void clearError() {
    _emitInstant(state.copyWith(errorMessage: null));
  }

  //==================== Permission Management - INSTANT UPDATES
  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.microphone.request();
      if (!_isDisposed) {
        _emitInstant(
          state.copyWith(
            hasRecordingPermission: status == PermissionStatus.granted,
          ),
        );
      }
      log(
        'Microphone permission: ${status == PermissionStatus.granted ? "GRANTED" : "DENIED"}',
      );
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(
          state.copyWith(
            errorMessage: 'Failed to check microphone permission: $e',
          ),
        );
      }
      log('Permission error: $e');
    }
  }

  //=============== Voice Recording Methods - INSTANT UPDATES
  Future<void> startRecording() async {
    try {
      log('Starting recording...');

      if (!state.hasRecordingPermission) {
        await _initializePermissions();
        if (!state.hasRecordingPermission) {
          _emitInstant(
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

        _emitInstant(
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
        _emitInstant(
          state.copyWith(errorMessage: 'Microphone permission denied'),
        );
      }
    } catch (e) {
      log('Error starting recording: $e');
      _emitInstant(
        state.copyWith(errorMessage: 'Failed to start recording: $e'),
      );
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRecording && !_isDisposed) {
        final newDuration = Duration(seconds: timer.tick);
        _emitInstant(state.copyWith(recordingDuration: newDuration));
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
            await createChat(
              AddChatEntryRequest(
                chatId: req.chatId,
                senderId: 45,
                type: 'N',
                typeValue: 0,
                messageType: 'voice',
                content: 'Voice message',
                source: 'Mobile',
              ),
              files: [file],
            );

            _emitInstant(
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
    _emitInstant(
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

      _emitInstant(
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

  //================== Chat API Methods - INSTANT UPDATES
  Future<void> getChatList() async {
    // INSTANT UI UPDATE - Show loading immediately
    _emitInstant(state.copyWith(isChat: ApiFetchStatus.loading));

    try {
      final res = await _chatRepositories.chatList();
      if (!_isDisposed) {
        if (res.data != null) {
          // INSTANT UI UPDATE - Show results immediately
          _emitInstant(
            state.copyWith(
              chatList: res.data,
              isChat: ApiFetchStatus.success,
              allChats: res.data,
              selectedTab: 'all',
            ),
          );
        } else {
          _emitInstant(
            state.copyWith(isChat: ApiFetchStatus.failed, chatList: []),
          );
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(
          state.copyWith(
            isChat: ApiFetchStatus.failed,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> getChatEntry({int? chatId, int? userId}) async {
    final currentChatId = chatId ?? 0;

    _emitInstant(state.copyWith(isChatEntry: ApiFetchStatus.loading));

    try {
      final res = await _chatRepositories.chatEntry(currentChatId, userId ?? 0);
      if (_isDisposed) return;

      if (res.data != null) {
        // INSTANT UI UPDATE - Show chat content immediately
        _emitInstant(
          state.copyWith(
            chatEntry: res.data,
            isChatEntry: ApiFetchStatus.success,
          ),
        );

        // Load media files in background without blocking UI
        if (res.data?.entries != null && res.data!.entries!.isNotEmpty) {
          _loadMediaInBackground(res.data!.entries!);
        }
      } else {
        _emitInstant(
          state.copyWith(isChatEntry: ApiFetchStatus.success, chatEntry: null),
        );
      }
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(
          state.copyWith(
            isChatEntry: ApiFetchStatus.failed,
            errorMessage: e.toString(),
          ),
        );
      }
      log('Error getting chat entry: $e');
    }
  }

  // Background Media Loading - NO UI BLOCKING
  void _loadMediaInBackground(List<Entry> entries) {
    if (_isDisposed) return;
    unawaited(_loadMediaFilesOptimized(entries));
  }

  Future<void> _loadMediaFilesOptimized(List<Entry> entries) async {
    if (_isDisposed) return;

    try {
      final mediaToLoad = <ChatMedias>[];
      for (final entry in entries) {
        if (entry.chatMedias?.isNotEmpty == true) {
          for (final media in entry.chatMedias!) {
            if (media.id != null && media.mediaUrl != null) {
              final mediaId = media.id.toString();
              if (!_isFileLoadedAndValid(mediaId) &&
                  !_failedLoads.contains(mediaId)) {
                mediaToLoad.add(media);
              }
            }
          }
        }
      }

      if (mediaToLoad.isEmpty) return;

      log('Background loading ${mediaToLoad.length} media files');

      const batchSize = 3;
      for (int i = 0; i < mediaToLoad.length; i += batchSize) {
        if (_isDisposed) break;
        final batch = mediaToLoad.skip(i).take(batchSize);
        final futures = batch.map(_loadSingleMediaFile);
        await Future.wait(futures, eagerError: false);
        _scheduleMediaUpdate();
        if (i + batchSize < mediaToLoad.length) {
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    } catch (e) {
      log('Background media loading error: $e');
    }
  }

  Future<void> _loadSingleMediaFile(ChatMedias media) async {
    if (_isDisposed || media.id == null || media.mediaUrl == null) return;
    final String mediaId = media.id.toString();
    if (_loadingFiles[mediaId] == true || _failedLoads.contains(mediaId)) {
      return;
    }
    if (_isFileLoadedAndValid(mediaId)) {
      return;
    }

    _loadingFiles[mediaId] = true;

    try {
      final fileData = await _chatRepositories.getFileFromApi(media.mediaUrl!);
      if (_isDisposed) return;
      _fileUrls[mediaId] = fileData['data'] ?? '';
      _fileTypes[mediaId] = fileData['type'] ?? 'unknown';
      _fileCacheTimestamps[mediaId] = DateTime.now();
      _failedLoads.remove(mediaId);

      log('Loaded media: $mediaId, type: ${fileData['type']}');
    } catch (e) {
      log('Error loading media $mediaId: $e');
      _failedLoads.add(mediaId);
      _fileUrls.remove(mediaId);
      _fileTypes.remove(mediaId);
      _fileCacheTimestamps.remove(mediaId);
    } finally {
      _loadingFiles[mediaId] = false;
    }
  }

  Future<void> loadMediaFile(ChatMedias media) async {
    if (_isDisposed) return;
    unawaited(_loadSingleMediaFile(media));
    if (media.id != null) {
      _loadingFiles[media.id.toString()] = true;
      _scheduleMediaUpdate();
    }
  }

  //=============== Enhanced createChat with INSTANT optimistic updates
  Future<void> createChat(
    AddChatEntryRequest request, {
    List<File>? files,
  }) async {
    if (_isDisposed) return;

    try {
      final messageText = request.content?.trim();
      if (messageText == null ||
          messageText.isEmpty && files?.isEmpty != false) {
        return;
      }
      final filesToSend = files ?? state.selectedFiles ?? [];
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final tempMessage = Entry(
        id: tempId,
        content: request.content ?? "File attachment",
        messageType: request.messageType,
        senderId: request.senderId,
        type: request.type,
        typeValue: request.typeValue,
        createdAt: DateTime.now().toIso8601String(),
        chatId: request.chatId,
      );
      final currentEntries = state.chatEntry?.entries ?? <Entry>[];
      final updatedEntries = List<Entry>.from(currentEntries)..add(tempMessage);

      _emitInstant(
        state.copyWith(
          chatEntry:
              state.chatEntry?.copyWith(entries: updatedEntries) ??
              ChatEntryResponse(entries: updatedEntries),
          selectedFiles: [],
        ),
      );
      final res = await _chatRepositories.addChatEntry(
        req: request,
        files: filesToSend,
      );

      if (_isDisposed) return;

      if (res.data != null) {
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
          chatMedias: res.data?.chatMedias,
        );

        final finalEntries = updatedEntries.map((entry) {
          return entry.id == tempId ? serverEntry : entry;
        }).toList();
        _emitInstant(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: finalEntries),
            // isChatEntry: ApiFetchStatus.success,
          ),
        );

        if (serverEntry.chatMedias?.isNotEmpty == true) {
          _loadMediaInBackground([serverEntry]);
        }
      } else {
        final failedEntries = updatedEntries
            .where((entry) => entry.id != tempId)
            .toList();

        _emitInstant(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: failedEntries),
            // isChatEntry: ApiFetchStatus.failed,
            errorMessage: 'Failed to send message',
          ),
        );
      }
    } catch (e) {
      log('Error creating chat entry: $e');
      if (!_isDisposed) {
        _emitInstant(
          state.copyWith(
            // isChatEntry: ApiFetchStatus.failed,
            errorMessage: 'Error: ${e.toString()}',
          ),
        );
      }
    }
  }

  // File Selection Methods - INSTANT UPDATES
  Future<void> selectFiles() async {
    if (_isDisposed) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true,
      );

      if (result != null && !_isDisposed) {
        final files = result.paths.map((path) => File(path!)).toList();
        final currentFiles = state.selectedFiles ?? [];
        final updatedFiles = [...currentFiles, ...files];

        // INSTANT UI UPDATE
        _emitInstant(state.copyWith(selectedFiles: updatedFiles));
        log('Selected ${files.length} files');
      }
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(state.copyWith(errorMessage: 'Error selecting files: $e'));
      }
      log('Error selecting files: $e');
    }
  }

  Future<void> selectImageFromGallery(BuildContext context) async {
    if (_isDisposed) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && !_isDisposed) {
        _addSelectedFile(File(image.path));
        context.pop();
        log('Selected image from gallery: ${image.path}');
      }
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(state.copyWith(errorMessage: 'Error selecting image: $e'));
      }
    }
  }

  Future<void> selectImageFromCamera() async {
    if (_isDisposed) return;

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && !_isDisposed) {
        _addSelectedFile(File(image.path));
        log('Captured image from camera: ${image.path}');
      }
    } catch (e) {
      if (!_isDisposed) {
        _emitInstant(state.copyWith(errorMessage: 'Error capturing image: $e'));
      }
    }
  }

  void _addSelectedFile(File file) {
    if (_isDisposed) return;

    final currentFiles = state.selectedFiles ?? [];
    final updatedFiles = [...currentFiles, file];
    // INSTANT UI UPDATE
    _emitInstant(state.copyWith(selectedFiles: updatedFiles));
  }

  void removeSelectedFile(int index) {
    if (_isDisposed) return;

    if (state.selectedFiles != null && index < state.selectedFiles!.length) {
      final updatedFiles = List<File>.from(state.selectedFiles!);
      updatedFiles.removeAt(index);
      // INSTANT UI UPDATE
      _emitInstant(state.copyWith(selectedFiles: updatedFiles));
      log('Removed file at index $index');
    }
  }

  void clearSelectedFiles() {
    if (_isDisposed) return;

    // INSTANT UI UPDATE
    _emitInstant(state.copyWith(selectedFiles: []));
    log('Cleared all selected files');
  }

  // Legacy method for backward compatibility
  Future<void> loadMediaFilesForEntries(List<Entry> entries) async {
    _loadMediaInBackground(entries);
  }

  // Cache Management
  bool _isFileLoadedAndValid(String mediaId) {
    if (!_fileUrls.containsKey(mediaId)) return false;

    final timestamp = _fileCacheTimestamps[mediaId];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  // Public getters for UI
  String? getFileUrl(String mediaId) => _fileUrls[mediaId];
  String? getFileType(String mediaId) => _fileTypes[mediaId];
  bool isFileLoading(String mediaId) => _loadingFiles[mediaId] == true;
  bool isFileLoaded(String mediaId) => _isFileLoadedAndValid(mediaId);

  // Tab Management - INSTANT UPDATES
  Future<void> selectedTab(String value) async {
    if (_isDisposed) return;

    // INSTANT UI UPDATE
    _emitInstant(state.copyWith(selectedTab: value));

    // Filter immediately without delay
    _filterChatList(value);
  }

  void _filterChatList(String selectedTab) {
    if (_isDisposed || state.allChats == null) return;

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

    // INSTANT UI UPDATE
    _emitInstant(
      state.copyWith(chatList: filteredChats, selectedTab: selectedTab),
    );
  }

  // Utility Methods
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> initStateClear() async {
    if (_isDisposed) return;

    // INSTANT UI UPDATE
    _emitInstant(state.copyWith(isArrow: false));
  }

  @override
  Future<void> close() {
    log('Closing ChatCubit...');
    _isDisposed = true;

    _recordingTimer?.cancel();
    _batchUpdateTimer?.cancel();
    _audioRecorder.dispose();

    return super.close();
  }
}

// Helper function for fire-and-forget futures
void unawaited(Future<void> future) {
  future.catchError((error) {
    log('Unawaited future error: $error');
  });
}
