import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
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

      // FIX: Check permission first, if not granted, request it
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

      // Generate recording path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final recordingPath = '${directory.path}/$fileName';
      log('Recording path: $recordingPath');

      // Check if recorder has permission
      if (await _audioRecorder.hasPermission()) {
        log('AudioRecorder has permission, starting...');

        // Start recording
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: recordingPath,
        );

        // Update state to recording
        emit(
          state.copyWith(
            isRecording: true,
            recordingPath: recordingPath,
            recordingDuration: Duration.zero,
            errorMessage: null,
          ),
        );

        log('State updated - isRecording: ${state.isRecording}');

        // FIX: Start timer with proper error handling
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

  // FIX: Enhanced timer with better logging and error handling
  void _startRecordingTimer() {
    log('Starting recording timer...');

    // Cancel any existing timer
    _recordingTimer?.cancel();

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      log('Timer tick: ${timer.tick}, isRecording: ${state.isRecording}');

      if (state.isRecording) {
        final newDuration = Duration(seconds: timer.tick);
        log('Updating duration to: ${formatDuration(newDuration)}');

        // FIX: Use a new state object to force rebuild
        emit(
          state.copyWith(
            recordingDuration: newDuration,
            // FIX: Force state change by updating a dummy field if needed
            errorMessage: null, // This ensures state actually changes
          ),
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

      // Stop timer first
      _recordingTimer?.cancel();
      log('Timer cancelled');

      // Stop recording
      final path = await _audioRecorder.stop();
      log('Recording stopped, path: $path');

      if (path != null && state.recordingPath != null) {
        // Validate file
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          final fileSize = await file.length();
          log('File exists, size: $fileSize bytes');

          if (fileSize > 0) {
            // Create voice message
            final voiceMessage = ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: state.recordingPath!,
              type: ChatMessageType.voice,
              isSent: true,
              timestamp: DateTime.now(),
              audioDuration: state.recordingDuration,
            );

            // Add message to chat
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

  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      log('Cancelling recording...');
      if (!state.isRecording) return;

      // Stop timer
      _recordingTimer?.cancel();
      log('Timer cancelled');

      // Stop recording
      await _audioRecorder.stop();
      log('Recording stopped');

      // Delete the recording file if it exists
      if (state.recordingPath != null) {
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          await file.delete();
          log('Recording file deleted: ${state.recordingPath}');
        }
      }

      // Reset recording state
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

  // Send text message
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

  // Add received message (simulate)
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

  // Format duration helper
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
      emit(state.copyWith(chatList: res.data, isChat: ApiFetchStatus.success));
    }
    emit(state.copyWith(isChat: ApiFetchStatus.failed));
  }

  Future<void> getChatEntry({int? chatId, int? userId}) async {
    emit(state.copyWith(isChatEntry: ApiFetchStatus.loading));
    final res = await _chatRepositories.chatEntry(chatId ?? 0, userId ?? 0);
    if (res.data != null) {
      emit(
        state.copyWith(
          chatEntry: res.data,
          isChatEntry: ApiFetchStatus.success,
        ),
      );
    }
    emit(state.copyWith(isChatEntry: ApiFetchStatus.failed));
  }

  @override
  Future<void> close() {
    log('Closing ChatCubit...');
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }
}
