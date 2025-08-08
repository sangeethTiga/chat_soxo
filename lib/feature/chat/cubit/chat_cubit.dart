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

  ChatCubit(this._chatRepositories) : super(InitilaChatState()) {
    _initializePermissions();
  }

  Future<void> arrowSelected() async {
    emit(state.copyWith(isArrow: !(state.isArrow)));
  }

  void resetState() {
    emit(state.copyWith(isArrow: false));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

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

  Future<void> startRecording() async {
    try {
      log('Starting recording...');
      log('Has permission: ${state.hasRecordingPermission}');

      if (!state.hasRecordingPermission) {
        log('No permission, requesting...');
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
      log('Recording path: $recordingPath');

      if (await _audioRecorder.hasPermission()) {
        log('AudioRecorder has permission, starting...');

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

        log('State updated - isRecording: ${state.isRecording}');

        _startRecordingTimer();

        log('Recording started successfully at: $recordingPath');
      } else {
        log('AudioRecorder permission denied');
        emit(state.copyWith(errorMessage: 'Microphone permission denied'));
      }
    } catch (e) {
      log('Error starting recording: $e');
      emit(state.copyWith(errorMessage: 'Failed to start recording: $e'));
    }
  }

  void _startRecordingTimer() {
    log('Starting recording timer...');

    _recordingTimer?.cancel();

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      log('Timer tick: ${timer.tick}, isRecording: ${state.isRecording}');

      if (state.isRecording) {
        final newDuration = Duration(seconds: timer.tick);
        log('Updating duration to: ${formatDuration(newDuration)}');

        // FIX: Use a new state object to force rebuild
        emit(
          state.copyWith(recordingDuration: newDuration, errorMessage: null),
        );

        log(
          'Duration updated in state: ${formatDuration(state.recordingDuration)}',
        );
      } else {
        log('Recording stopped, cancelling timer');
        timer.cancel();
      }
    });

    log('Recording timer started successfully');
  }

  Future<void> stopRecordingAndSend() async {
    try {
      log('Stopping recording...');
      if (!state.isRecording) {
        log('Not currently recording, returning');
        return;
      }

      _recordingTimer?.cancel();
      log('Timer cancelled');

      final path = await _audioRecorder.stop();
      log('Recording stopped, path: $path');

      if (path != null && state.recordingPath != null) {
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          final fileSize = await file.length();
          log('File exists, size: $fileSize bytes');

          if (fileSize > 0) {
            await createChat(
              AddChatEntryRequest(
                chatId: null, // Set appropriate chatId
                senderId: 45, // Set appropriate senderId
                type: 'N',
                typeValue: 0,
                messageType: 'voice',
                content: 'Voice message',
                source: 'Website',
              ),
              files: [file], // Pass the voice file
            );

            emit(
              state.copyWith(
                isRecording: false,
                recordingDuration: Duration.zero,
                recordingPath: null,
                errorMessage: null,
              ),
            );
            final voiceMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: state.recordingPath!,
              type: ChatMessageType.voice,
              isSent: true,
              timestamp: DateTime.now(),
              audioDuration: state.recordingDuration,
            );

            final updatedMessages = [...state.messages, voiceMessage];

            emit(
              state.copyWith(
                isRecording: false,
                recordingDuration: Duration.zero,
                recordingPath: null,
                messages: updatedMessages,
                errorMessage: null,
              ),
            );

            log(
              'Voice message sent: ${formatDuration(voiceMessage.audioDuration!)}',
            );
          } else {
            log('File is empty');
            emit(
              state.copyWith(
                isRecording: false,
                recordingDuration: Duration.zero,
                recordingPath: null,
                errorMessage: 'Recording failed - file is empty',
              ),
            );
          }
        } else {
          log('File does not exist');
          emit(
            state.copyWith(
              isRecording: false,
              recordingDuration: Duration.zero,
              recordingPath: null,
              errorMessage: 'Recording failed - file not found',
            ),
          );
        }
      } else {
        log('No recording path');
        emit(
          state.copyWith(
            isRecording: false,
            recordingDuration: Duration.zero,
            recordingPath: null,
            errorMessage: 'Recording failed - no file path',
          ),
        );
      }
    } catch (e) {
      log('Error stopping recording: $e');
      emit(
        state.copyWith(
          isRecording: false,
          recordingDuration: Duration.zero,
          recordingPath: null,
          errorMessage: 'Failed to stop recording: $e',
        ),
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      log('Cancelling recording...');
      if (!state.isRecording) return;

      _recordingTimer?.cancel();
      log('Timer cancelled');

      await _audioRecorder.stop();
      log('Recording stopped');

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

      log('Recording cancelled successfully');
    } catch (e) {
      log('Error cancelling recording: $e');
      emit(
        state.copyWith(
          isRecording: false,
          recordingDuration: Duration.zero,
          recordingPath: null,
          errorMessage: 'Failed to cancel recording: $e',
        ),
      );
    }
  }

  void sendTextMessage(String message) {
    if (message.trim().isEmpty) return;

    final textMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message.trim(),
      type: ChatMessageType.text,
      isSent: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, textMessage];

    emit(state.copyWith(messages: updatedMessages, errorMessage: null));

    log('Text message sent: ${textMessage.content}');
  }

  void addReceivedMessage(String message, {String? senderName}) {
    final receivedMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      type: ChatMessageType.text,
      isSent: false,
      timestamp: DateTime.now(),
      senderName: senderName ?? 'Dr Habeeb',
    );

    final updatedMessages = [...state.messages, receivedMessage];

    emit(state.copyWith(messages: updatedMessages));
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> getChatList() async {
    emit(state.copyWith(isChat: ApiFetchStatus.loading));
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

  Future<void> selectedTab(String value) async {
    final previousChatList = state.chatList;
    emit(state.copyWith(selectedTab: value));

    if (previousChatList != null && previousChatList.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _filterChatList(value);
  }

  void _filterChatList(String selectedTab) {
    if (state.allChats == null) {
      return;
    }
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

  Future<void> initStateClear() async {
    emit(state.copyWith(isArrow: false));
  }

  //=-=-=-=-=-=-=-=-=-=
  Future<void> createChat(
    AddChatEntryRequest request, {
    List<File>? files,
  }) async {
    final messageText = request.content?.trim();
    if (messageText == null || messageText.isEmpty) return;
    final filesToSend = files ?? state.selectedFiles ?? [];

    final hasFiles =
        (files?.isNotEmpty ?? false) ||
        (state.selectedFiles?.isNotEmpty ?? false);
    if (filesToSend.isNotEmpty) {
      final firstFile = filesToSend.first;
      final extension = firstFile.path.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        // messageType = 'image';
      } else if (extension == 'pdf') {
        // messageType = 'document';
      }
    }
    final tempMessage = Entry(
      id: request.chatId,
      content: request.content ?? "File attachment",
      messageType: request.messageType,
      senderId: request.senderId,
      type: request.type,
      typeValue: request.typeValue,
      createdAt: DateTime.now().toIso8601String(),
    );

    final currentEntries = state.chatEntry?.entries ?? <Entry>[];
    final updatedEntries = List<Entry>.from(currentEntries)..add(tempMessage);
    emit(
      state.copyWith(
        chatEntry:
            state.chatEntry?.copyWith(entries: updatedEntries) ??
            ChatEntryResponse(entries: updatedEntries),
      ),
    );

    try {
      final res = await _chatRepositories.addChatEntry(
        req: request,
        files: filesToSend,
      );

      if (res.data != null) {
        final serverEntry = Entry(
          id: res.data?.id,
          content: res.data!.content,
          messageType: res.data!.messageType,
          senderId: res.data!.senderId,
          type: res.data!.type,
          typeValue: res.data?.typeValue,
          createdAt: res.data!.createdAt?.toString(),
          chatId: res.data!.chatId,
          thread: res.data?.thread,
        );
        final finalEntries = updatedEntries.map((entry) {
          if (entry.id == tempMessage.id) {
            return serverEntry;
          }
          return entry;
        }).toList();
        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: finalEntries),
            isChatEntry: ApiFetchStatus.success,
            selectedFiles: state.selectedFiles,
          ),
        );
      } else {
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
      final errorEntries = updatedEntries
          .where((entry) => entry.id != tempMessage.id)
          .toList();

      emit(
        state.copyWith(
          chatEntry: state.chatEntry?.copyWith(entries: errorEntries),
          isChatEntry: ApiFetchStatus.failed,
          errorMessage: 'Error: ${e.toString()}',
        ),
      );
      log('Error creating chat entry: $e');
    }
  }

  Future<void> selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        List<File> currentFiles = state.selectedFiles ?? [];
        List<File> updatedFiles = [...currentFiles, ...files];

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
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<File> currentFiles = state.selectedFiles ?? [];
        List<File> updatedFiles = [...currentFiles, File(image.path)];

        emit(state.copyWith(selectedFiles: updatedFiles));
        log('Selected image from gallery: ${image.path}');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error selecting image: $e'));
      log('Error selecting image: $e');
    }
  }

  Future<void> selectImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        List<File> currentFiles = state.selectedFiles ?? [];
        List<File> updatedFiles = [...currentFiles, File(image.path)];

        emit(state.copyWith(selectedFiles: updatedFiles));
        log('Captured image from camera: ${image.path}');
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error capturing image: $e'));
      log('Error capturing image: $e');
    }
  }

  void removeSelectedFile(int index) {
    if (state.selectedFiles != null && index < state.selectedFiles!.length) {
      List<File> updatedFiles = List.from(state.selectedFiles!);
      updatedFiles.removeAt(index);
      emit(state.copyWith(selectedFiles: updatedFiles));
      log('Removed file at index $index');
    }
  }

  void clearSelectedFiles() {
    emit(state.copyWith(selectedFiles: []));
    log('Cleared all selected files');
  }

  //=-=-=-=
  @override
  Future<void> close() {
    log('Closing ChatCubit...');
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }
}
