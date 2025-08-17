import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:soxo_chat/feature/chat/domain/models/add_chat/add_chatentry_request.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/chat/domain/repositories/chat_repositories.dart';
import 'package:soxo_chat/feature/chat/domain/service/signalR_service.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/media/media_cache.dart';

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

  final Map<int, ChatEntryResponse> _chatCache = {};
  final Map<int, DateTime> _chatCacheTimestamps = {};
  int? _currentChatId;

  Timer? _batchUpdateTimer;
  bool _hasPendingUpdates = false;
  bool _isDisposed = false;
  final bool _isSignalRInitialized = false;
  static const Duration _cacheExpiration = Duration(hours: 2);
  static const Duration _chatCacheExpiration = Duration(minutes: 10);
  static const Duration _batchDelay = Duration(milliseconds: 16);
  final ChatSignalRService _signalRService = ChatSignalRService();

  ChatCubit(this._chatRepositories) : super(InitialChatState()) {
    _initializePermissions();
    _initializeSignalR();
  }

  void _scheduleMediaUpdate() {
    if (_isDisposed) return;

    _hasPendingUpdates = true;
    _batchUpdateTimer?.cancel();

    // ✅ IMMEDIATE UPDATE for better UX
    _batchUpdateTimer = Timer(const Duration(milliseconds: 50), () {
      if (_hasPendingUpdates && !_isDisposed) {
        log('🔄 Emitting media update state');
        log('📊 Current file URLs: ${_fileUrls.keys.length}');

        // ✅ Log what's being emitted
        _fileUrls.forEach((id, url) {
          log('   Media $id: ${url.length} chars, type: ${_fileTypes[id]}');
        });

        final newState = state.copyWith(
          fileUrls: Map<String, String>.from(_fileUrls),
          fileTypes: Map<String, String>.from(_fileTypes),
        );

        emit(newState);
        _hasPendingUpdates = false;

        log('✅ Media state emitted - should trigger UI rebuild');
      }
    });
  }

  Future<void> arrowSelected() async {
    emit(state.copyWith(isArrow: !state.isArrow));
  }

  void resetState() {
    emit(state.copyWith(isArrow: false));
  }

  void resetChatState() {
    if (_isDisposed) return;

    log('🔄 Resetting chat state');

    emit(
      state.copyWith(
        isChatEntry: ApiFetchStatus.idle, // ✅ Set to idle, not loading
        chatEntry: null,
        errorMessage: null,
        isArrow: false,
      ),
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void _initializeSignalR() {
    _signalRService.onChatEntryReceived = _handleNewChatEntry;
    _signalRService.onNewEntriesReceived = _handleNewEntries;
    _signalRService.onEntryUpdated = _handleEntryUpdate;
    _signalRService.onEntryDeleted = _handleEntryDeletion;
    _signalRService.onConnected = _handleSignalRConnected;
    _signalRService.onMessageReceived = _handleMessageReceived; // ✅ Add this
    _signalRService.onDisconnected = _handleSignalRDisconnected; // ✅ Add this
    _signalRService.onError = _handleSignalRError;
    _connectSignalR();
  }

  Future<void> _connectSignalR() async {
    try {
      await _signalRService.initializeConnection();
      log('✅ SignalR connected successfully');
    } catch (e) {
      log('❌ SignalR connection failed: $e');
    }
  }

  void _handleMessageReceived(dynamic message) {
    log('📨 SignalR: Generic message received: $message');

    // Handle different message types
    if (message == "REGISTRATION") {
      log('📋 Registration confirmed, refreshing chat data...');
      if (_currentChatId != null) {
        // Refresh current chat data
        getChatEntry(chatId: _currentChatId);
      }
    } else if (message is String && message.contains("NEW_MESSAGE")) {
      log('📬 New message notification received');
      // Handle new message notification
    }
  }

  // ✅ NEW: Handle disconnections
  void _handleSignalRDisconnected() {
    log('🔌 SignalR disconnected');
    emit(state.copyWith(errorMessage: 'Connection lost. Reconnecting...'));
  }

  // ✅ NEW: Handle errors
  void _handleSignalRError(Exception? error) {
    log('❌ SignalR error: $error');
    emit(state.copyWith(errorMessage: 'Connection error: $error'));
  }

  void _handleSignalRConnected() {
    log('🔗 SignalR connected successfully');

    // Clear any connection error messages
    if (state.errorMessage?.contains('Connection') == true) {
      emit(state.copyWith(errorMessage: null));
    }

    // Rejoin current chat if exists
    if (_currentChatId != null) {
      log('🔄 Rejoining chat group: $_currentChatId');
      _signalRService.joinChatGroup(_currentChatId.toString());

      // Request updates for current chat
      // _signalRService.requestChatEntry(
      //   _currentChatId.toString(),
      //   '0', // You might want to pass the actual user ID
      // );
    }
  }

  void _handleNewEntries(List<Entry> newEntries) {
    log('📨 SignalR: Received ${newEntries.length} new entries');
    log('📊 Current chat ID: $_currentChatId');
    log('📊 Has state.chatEntry: ${state.chatEntry != null}');

    // Print detailed entry information
    for (var entry in newEntries) {
      log(
        '📝 Entry: ID=${entry.id}, ChatID=${entry.chatId}, Content=${entry.content}',
      );
      log(
        '📝 MessageType: ${entry.messageType}, Media: ${entry.chatMedias?.length ?? 0} items',
      );

      // Log media details
      if (entry.chatMedias?.isNotEmpty == true) {
        for (var media in entry.chatMedias!) {
          log(
            '📎 Media: ID=${media.id}, Type=${media.mediaType}, URL=${media.mediaUrl?.substring(0, 50)}...',
          );
        }
      }
    }

    if (_currentChatId == null) {
      log('⚠️ No current chat ID set');
      return;
    }

    if (state.chatEntry == null) {
      log('⚠️ No chat entry state');
      return;
    }

    // Filter entries for current chat
    final relevantEntries = newEntries.where((entry) {
      final entryChat = entry.chatId?.toString();
      final currentChat = _currentChatId.toString();
      log('🔍 Comparing entry chat: "$entryChat" with current: "$currentChat"');
      return entryChat == currentChat;
    }).toList();

    log('📊 Relevant entries for current chat: ${relevantEntries.length}');

    if (relevantEntries.isNotEmpty) {
      final currentEntries = state.chatEntry!.entries ?? [];
      final existingIds = currentEntries.map((e) => e.id).toSet();
      final filteredNewEntries = relevantEntries
          .where((entry) => !existingIds.contains(entry.id))
          .toList();

      log(
        '📊 New entries after filtering duplicates: ${filteredNewEntries.length}',
      );

      if (filteredNewEntries.isNotEmpty) {
        final updatedChatEntry = state.chatEntry!.copyWith(
          entries: [...currentEntries, ...filteredNewEntries],
        );

        // Update cache
        _chatCache[_currentChatId!] = updatedChatEntry;
        _chatCacheTimestamps[_currentChatId!] = DateTime.now();

        // ✅ IMPORTANT: Emit new state
        emit(
          state.copyWith(
            chatEntry: updatedChatEntry,
            isChatEntry: ApiFetchStatus.success,
          ),
        );

        // ✅ IMPORTANT: Load media for new entries immediately
        for (var entry in filteredNewEntries) {
          if (entry.chatMedias?.isNotEmpty == true) {
            log('📎 Loading media for new entry: ${entry.id}');
            _loadMediaInBackground([entry]);
          }
        }

        log('✅ State updated with ${filteredNewEntries.length} new entries');
        log('📊 Total entries now: ${updatedChatEntry.entries?.length}');
        debugMediaState();
        // ✅ ADD VISUAL FEEDBACK
        // You could add a brief animation or notification here
      } else {
        log('ℹ️ All entries already exist (duplicates filtered)');
      }
    } else {
      log('ℹ️ No relevant entries for current chat $_currentChatId');
    }
  }

  // ✅ FIXED: Enhanced event handlers with better chat ID matching
  void _handleNewChatEntry(ChatEntryResponse newChatEntry) {
    log(
      '📨 SignalR: Received new chat entry with ${newChatEntry.entries?.length ?? 0} entries',
    );

    if (_currentChatId == null || state.chatEntry == null) {
      log('⚠️ SignalR: No current chat or chat entry to update');
      return;
    }

    // Filter entries that belong to current chat
    final relevantEntries =
        newChatEntry.entries?.where((entry) {
          final entryChat = entry.chatId?.toString();
          final currentChat = _currentChatId.toString();
          log('🔍 Comparing entry chat: $entryChat with current: $currentChat');
          return entryChat == currentChat;
        }).toList() ??
        [];

    log(
      '📊 Found ${relevantEntries.length} relevant entries for chat $_currentChatId',
    );

    if (relevantEntries.isNotEmpty) {
      final currentEntries = state.chatEntry!.entries ?? [];

      // Filter out duplicates based on entry ID
      final existingIds = currentEntries.map((e) => e.id).toSet();
      final newEntries = relevantEntries
          .where((entry) => !existingIds.contains(entry.id))
          .toList();

      log('📊 New entries after duplicate filtering: ${newEntries.length}');

      if (newEntries.isNotEmpty) {
        final updatedChatEntry = state.chatEntry!.copyWith(
          entries: [...currentEntries, ...newEntries],
        );

        // Update cache
        _chatCache[_currentChatId!] = updatedChatEntry;
        _chatCacheTimestamps[_currentChatId!] = DateTime.now();

        // Emit updated state
        emit(
          state.copyWith(
            chatEntry: updatedChatEntry,
            isChatEntry: ApiFetchStatus.success,
          ),
        );

        // Load media for new entries
        _loadMediaInBackground(newEntries);

        log('✅ Added ${newEntries.length} new entries to chat $_currentChatId');
      } else {
        log('ℹ️ No new entries to add (all already exist)');
      }
    } else {
      log('ℹ️ No relevant entries for current chat $_currentChatId');
    }
  }

  void _handleEntryUpdate(Entry updatedEntry) {
    log('📝 SignalR: Entry updated - ${updatedEntry.id}');

    if (_currentChatId == null || state.chatEntry == null) {
      log('⚠️ SignalR: No current chat context for entry update');
      return;
    }

    // Check if this entry belongs to current chat
    if (updatedEntry.chatId?.toString() != _currentChatId.toString()) {
      log('ℹ️ SignalR: Entry update not for current chat');
      return;
    }

    final currentEntries = state.chatEntry!.entries ?? [];
    final updatedEntries = currentEntries.map((entry) {
      return entry.id == updatedEntry.id ? updatedEntry : entry;
    }).toList();

    final updatedChatEntry = state.chatEntry!.copyWith(entries: updatedEntries);

    // Update cache
    _chatCache[_currentChatId!] = updatedChatEntry;
    _chatCacheTimestamps[_currentChatId!] = DateTime.now();

    // Emit updated state
    emit(
      state.copyWith(
        chatEntry: updatedChatEntry,
        isChatEntry: ApiFetchStatus.success,
      ),
    );

    log('✅ Entry ${updatedEntry.id} updated in chat');
  }

  void _handleEntryDeletion(String entryId) {
    log('🗑️ SignalR: Entry deleted - $entryId');

    if (_currentChatId == null || state.chatEntry == null) {
      log('⚠️ SignalR: No current chat context for entry deletion');
      return;
    }

    final currentEntries = state.chatEntry!.entries ?? [];
    final filteredEntries = currentEntries
        .where((entry) => entry.id != entryId)
        .toList();

    // Only update if an entry was actually removed
    if (filteredEntries.length < currentEntries.length) {
      final updatedChatEntry = state.chatEntry!.copyWith(
        entries: filteredEntries,
      );

      // Update cache
      _chatCache[_currentChatId!] = updatedChatEntry;
      _chatCacheTimestamps[_currentChatId!] = DateTime.now();

      // Emit updated state
      emit(
        state.copyWith(
          chatEntry: updatedChatEntry,
          isChatEntry: ApiFetchStatus.success,
        ),
      );

      log('✅ Entry $entryId deleted from chat');
    } else {
      log('ℹ️ Entry $entryId not found in current chat');
    }
  }

  Future<void> getChatEntry({int? chatId, int? userId}) async {
    final currentChatId = chatId ?? 0;
    log('📱 Getting chat entry for chatId: $currentChatId');

    // Set current chat ID BEFORE any operations
    final previousChatId = _currentChatId;
    _currentChatId = currentChatId;

    // Always show loading first
    emit(
      state.copyWith(
        isChatEntry: ApiFetchStatus.loading,
        chatEntry: null,
        errorMessage: null,
      ),
    );

    if (_isDisposed) return;

    // Handle chat switching
    if (previousChatId != null && previousChatId != currentChatId) {
      log('🔄 Switching chats: $previousChatId -> $currentChatId');
    }

    // ✅ ALWAYS join SignalR group for this chat FIRST
    if (_signalRService.isConnected) {
      await _signalRService.joinChatGroup(currentChatId.toString());
      log('🔗 Joining SignalR group for chat $currentChatId');

      // // ✅ IMPORTANT: Request chat entry via SignalR
      // await _signalRService.requestChatEntry(
      //   currentChatId.toString(),
      //   (userId ?? 0).toString(),
      // );
      log('📡 Requested SignalR updates for chat $currentChatId');
    } else {
      log('⚠️ SignalR not connected, cannot join group');
    }

    // Check cache
    final cachedData = _chatCache[currentChatId];
    final cacheTimestamp = _chatCacheTimestamps[currentChatId];
    final isCacheValid =
        cachedData != null &&
        cacheTimestamp != null &&
        DateTime.now().difference(cacheTimestamp) < _chatCacheExpiration;

    // Use cached data if valid
    if (isCacheValid) {
      log('💾 Using cached data for chat $currentChatId');
      await Future.delayed(const Duration(milliseconds: 400));

      if (_isDisposed) return;

      emit(
        state.copyWith(
          chatEntry: cachedData,
          isChatEntry: ApiFetchStatus.success,
        ),
      );

      if (cachedData.entries?.isNotEmpty == true) {
        _loadMediaInBackground(cachedData.entries!);
      }
      return;
    }

    // Make API call for fresh data
    try {
      log('🌐 Making API call for chat $currentChatId');
      final res = await _chatRepositories.chatEntry(currentChatId, userId ?? 0);

      if (_isDisposed) return;

      if (res.data != null) {
        // Store in cache
        _chatCache[currentChatId] = res.data!;
        _chatCacheTimestamps[currentChatId] = DateTime.now();

        log('✅ Successfully loaded chat entry for chat $currentChatId');
        log('📊 Loaded ${res.data!.entries?.length ?? 0} entries');

        emit(
          state.copyWith(
            chatEntry: res.data,
            isChatEntry: ApiFetchStatus.success,
          ),
        );

        // Load media in background
        if (res.data?.entries != null && res.data!.entries!.isNotEmpty) {
          _loadMediaInBackground(res.data!.entries!);
        }
      } else {
        log('⚠️ No data received for chat $currentChatId');
        emit(
          state.copyWith(isChatEntry: ApiFetchStatus.success, chatEntry: null),
        );
      }
    } catch (e) {
      log('❌ Error getting chat entry for chat $currentChatId: $e');
      if (!_isDisposed) {
        emit(
          state.copyWith(
            isChatEntry: ApiFetchStatus.failed,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  void debugMediaState() {
    log('🔍 ===== Media Debug State =====');
    log('📊 File URLs count: ${_fileUrls.length}');
    log('📊 File types count: ${_fileTypes.length}');
    log('📊 Loading files count: ${_loadingFiles.length}');
    log('📊 Failed loads count: ${_failedLoads.length}');

    log('📂 File URLs:');
    _fileUrls.forEach((id, url) {
      log('   $id: ${url.substring(0, math.min(100, url.length))}...');
    });

    log('📂 File Types:');
    _fileTypes.forEach((id, type) {
      log('   $id: $type');
    });

    log('🔄 Currently Loading:');
    _loadingFiles.forEach((id, loading) {
      if (loading) log('   $id: loading');
    });

    log('❌ Failed Loads:');
    for (var id in _failedLoads) {
      log('   $id: failed');
    }

    log('🔍 ===============================');
  }

  void debugSignalRState() {
    log('🔍 ===== SignalR Debug State =====');
    log('  - ChatCubit._currentChatId: $_currentChatId');
    log('  - SignalR.isConnected: ${_signalRService.isConnected}');
    // log('  - SignalR._currentChatId: ${_signalRService}');
    log(
      '  - State.chatEntry entries: ${state.chatEntry?.entries?.length ?? 0}',
    );
    log('  - State.isChatEntry: ${state.isChatEntry}');
    log('🔍 ===============================');

    // Also print connection info
    _signalRService.printConnectionInfo();
  }

  Future<void> syncWithSignalR() async {
    if (_currentChatId != null && _signalRService.isConnected) {
      log('🔄 Manually syncing with SignalR for chat $_currentChatId');
      await _signalRService.joinChatGroup(_currentChatId.toString());
      await _signalRService.testServerConnection();
    }
  }
  // Future<void> getChatEntry({int? chatId, int? userId}) async {
  //   final currentChatId = chatId ?? 0;
  //   log('📱 Getting chat entry for chatId: $currentChatId');

  //   // ✅ ALWAYS show loading first, regardless of cache
  //   emit(
  //     state.copyWith(
  //       isChatEntry: ApiFetchStatus.loading,
  //       chatEntry: null, // Clear previous data
  //       errorMessage: null,
  //     ),
  //   );

  //   // ✅ Add a small delay to ensure shimmer is visible

  //   if (_isDisposed) return;

  //   // Check if we already have valid cached data for this chat
  //   final cachedData = _chatCache[currentChatId];
  //   final cacheTimestamp = _chatCacheTimestamps[currentChatId];
  //   final isCacheValid =
  //       cachedData != null &&
  //       cacheTimestamp != null &&
  //       DateTime.now().difference(cacheTimestamp) < _chatCacheExpiration;

  //   // If switching to a different chat, clear current state first
  //   if (_currentChatId != null && _currentChatId != currentChatId) {
  //     log('🔄 Switching chats: $_currentChatId -> $currentChatId');
  //   }

  //   _currentChatId = currentChatId;

  //   // Use cached data if valid (but we already showed loading)
  //   if (isCacheValid) {
  //     log('💾 Using cached data for chat $currentChatId');

  //     // ✅ Add delay even for cached data to show shimmer briefly
  //     await Future.delayed(const Duration(milliseconds: 400));

  //     if (_isDisposed) return;

  //     emit(
  //       state.copyWith(
  //         chatEntry: cachedData,
  //         isChatEntry: ApiFetchStatus.success,
  //       ),
  //     );

  //     // Load media in background for cached data
  //     if (cachedData.entries?.isNotEmpty == true) {
  //       _loadMediaInBackground(cachedData.entries!);
  //     }
  //     return;
  //   }

  //   try {
  //     log('🌐 Making API call for chat $currentChatId (no valid cache)');
  //     final res = await _chatRepositories.chatEntry(currentChatId, userId ?? 0);

  //     if (_isDisposed) return;

  //     if (res.data != null) {
  //       // Store in cache
  //       _chatCache[currentChatId] = res.data!;
  //       _chatCacheTimestamps[currentChatId] = DateTime.now();

  //       log(
  //         'Successfully loaded and cached chat entry for chat $currentChatId',
  //       );
  //       emit(
  //         state.copyWith(
  //           chatEntry: res.data,
  //           isChatEntry: ApiFetchStatus.success,
  //         ),
  //       );

  //       // Load media files in background
  //       if (res.data?.entries != null && res.data!.entries!.isNotEmpty) {
  //         _loadMediaInBackground(res.data!.entries!);
  //       }
  //     } else {
  //       log('⚠️ No data received for chat $currentChatId');
  //       emit(
  //         state.copyWith(isChatEntry: ApiFetchStatus.success, chatEntry: null),
  //       );
  //     }
  //   } catch (e) {
  //     log('Error getting chat entry for chat $currentChatId: $e');
  //     if (!_isDisposed) {
  //       emit(
  //         state.copyWith(
  //           isChatEntry: ApiFetchStatus.failed,
  //           errorMessage: e.toString(),
  //         ),
  //       );
  //     }
  //   }
  // }

  ///=-=-=-=-=-=-=-=-=  Method to refresh chat data (force refresh)
  Future<void> refreshChatEntry({int? chatId, int? userId}) async {
    final currentChatId = chatId ?? 0;
    log('🔄 Force refreshing chat entry for chatId: $currentChatId');

    ///=-=-=-=-=-=-=-=-=  Clear cache for this chat
    _chatCache.remove(currentChatId);
    _chatCacheTimestamps.remove(currentChatId);

    ///=-=-=-=-=-=-=-=-=  Show loading
    emit(state.copyWith(isChatEntry: ApiFetchStatus.loading));

    ///=-=-=-=-=-=-=-=-=  Fetch fresh data
    await getChatEntry(chatId: chatId, userId: userId);
  }

  ///=-=-=-=-=-=-=-=-=  Method to update chat cache when new message is added
  void _updateChatCache(int chatId, Entry newEntry) {
    final cachedData = _chatCache[chatId];
    if (cachedData != null) {
      final updatedEntries = List<Entry>.from(cachedData.entries ?? [])
        ..add(newEntry);

      _chatCache[chatId] = cachedData.copyWith(entries: updatedEntries);
      _chatCacheTimestamps[chatId] = DateTime.now();
    }
  }

  //==================== Permission Management - INSTANT UPDATES
  Future<void> _initializePermissions() async {
    try {
      final status = await Permission.microphone.request();
      if (!_isDisposed) {
        emit(
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
        emit(
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
      if (state.isRecording && !_isDisposed) {
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
      final user = await AuthUtils.instance.readUserData();
      if (path != null && state.recordingPath != null) {
        final file = File(state.recordingPath!);
        if (await file.exists()) {
          final fileSize = await file.length();

          if (fileSize > 0) {
            await createChat(
              AddChatEntryRequest(
                chatId: req.chatId,
                senderId:
                    int.tryParse(user?.result?.userId.toString() ?? '') ?? 0,
                type: 'N',
                typeValue: 0,
                messageType: 'voice',
                content: 'Voice message',
                source: 'Mobile',
              ),
              files: [file],
            );

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

  void sendTextMessage(String message, AddChatEntryRequest req) async {
    if (message.trim().isEmpty) return;
    final user = await AuthUtils.instance.readUserData();

    final request = AddChatEntryRequest(
      chatId: req.chatId,
      senderId: int.tryParse(user?.result?.userId.toString() ?? '') ?? 0,
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
    log('🔄 getChatList started');
    emit(state.copyWith(isChat: ApiFetchStatus.loading));

    try {
      final res = await _chatRepositories.chatList();

      log('📡 API Response: ${res.data?.length ?? 0} chats received');

      if (!_isDisposed && res.data != null) {
        // ✅ Don't override selectedTab - preserve current selection
        final currentTab = state.selectedTab ?? 'all';

        log('📊 Setting ${res.data!.length} chats to allChats');
        log('🎯 Current tab: $currentTab');

        emit(
          state.copyWith(
            chatList: res.data, // Initially show all 45
            isChat: ApiFetchStatus.success,
            allChats: res.data, // Store all 45
            selectedTab: currentTab, // ✅ Keep current tab
          ),
        );

        log('✅ State emitted with ${res.data!.length} chats');

        // ✅ Only filter if tab is not 'all'
        if (currentTab != 'all') {
          log('🔍 Applying filter for non-all tab: $currentTab');
          _filterChatList(currentTab);
        }
      }
    } catch (e) {
      log('❌ Error in getChatList: $e');
      if (!_isDisposed) {
        emit(
          state.copyWith(
            isChat: ApiFetchStatus.failed,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  ///=-=-=-=-=-=-=-=-=  Background Media Loading - NO UI BLOCKING
  void _loadMediaInBackground(List<Entry> entries) {
    if (_isDisposed) return;

    log('📎 Starting background media loading for ${entries.length} entries');

    // Process immediately for real-time messages
    for (final entry in entries) {
      if (entry.chatMedias?.isNotEmpty == true) {
        log('📎 Entry ${entry.id} has ${entry.chatMedias!.length} media items');

        for (final media in entry.chatMedias!) {
          if (media.id != null && media.mediaUrl != null) {
            final mediaId = media.id.toString();
            log('📎 Processing media: $mediaId, type: ${media.mediaType}');
            log('📎 Media URL: ${media.mediaUrl}');

            // ✅ Load immediately for real-time messages
            unawaited(_loadSingleMediaFile(media));
          } else {
            log(
              '⚠️ Skipping invalid media: ID=${media.id}, URL=${media.mediaUrl}',
            );
          }
        }
      } else {
        log('ℹ️ Entry ${entry.id} has no media');
      }
    }

    // Also trigger the optimized batch loading
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
    if (_isDisposed || media.id == null || media.mediaUrl == null) {
      log(
        '❌ Cannot load media: disposed=$_isDisposed, id=${media.id}, url=${media.mediaUrl}',
      );
      return;
    }

    final String mediaId = media.id.toString();
    log('📎 Starting media load for ID: $mediaId');

    if (_loadingFiles[mediaId] == true || _failedLoads.contains(mediaId)) {
      log('⚠️ Media $mediaId already loading or failed');
      return;
    }

    if (_isFileLoadedAndValid(mediaId)) {
      log('✅ Media $mediaId already loaded and valid');
      return;
    }

    _loadingFiles[mediaId] = true;

    try {
      log('📡 Calling getFileFromApi for media $mediaId...');
      final fileData = await _chatRepositories.getFileFromApi(media.mediaUrl!);

      if (_isDisposed) return;

      log('📡 API Response for media $mediaId:');
      log('   - Data exists: ${fileData['data'] != null}');
      log('   - File type: ${fileData['type']}');

      if (fileData['data'] != null && fileData['data'].toString().isNotEmpty) {
        _fileUrls[mediaId] = fileData['data'] ?? '';
        _fileTypes[mediaId] = fileData['type'] ?? 'unknown';
        _fileCacheTimestamps[mediaId] = DateTime.now();
        _failedLoads.remove(mediaId);

        log('✅ Successfully stored media $mediaId:');
        log('   - Type: ${_fileTypes[mediaId]}');
        log('   - URL length: ${_fileUrls[mediaId]?.length}');

        // ✅ FORCE IMMEDIATE UI UPDATE
        emit(
          state.copyWith(
            fileUrls: Map<String, String>.from(_fileUrls),
            fileTypes: Map<String, String>.from(_fileTypes),
          ),
        );

        log('🚀 IMMEDIATE state emission for media $mediaId');
      } else {
        throw Exception('Empty or invalid file data received');
      }
    } catch (e) {
      log('❌ Error loading media $mediaId: $e');
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

      ///=-=-=-=-=-=-=-=-=  Optimistic UI update
      emit(
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

        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: finalEntries),
          ),
        );

        ///=-=-=-=-=-=-=-=-=  Update cache with new message
        if (request.chatId != null) {
          _updateChatCache(request.chatId!, serverEntry);
        }

        if (serverEntry.chatMedias?.isNotEmpty == true) {
          _loadMediaInBackground([serverEntry]);
        }
      } else {
        ///=-=-=-=-=-=-=-=-=  Remove failed message
        final failedEntries = updatedEntries
            .where((entry) => entry.id != tempId)
            .toList();

        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: failedEntries),
            errorMessage: 'Failed to send message',
          ),
        );
      }
    } catch (e) {
      log('Error creating chat entry: $e');
      if (!_isDisposed) {
        emit(state.copyWith(errorMessage: 'Error: ${e.toString()}'));
      }
    }
  }

  ///=-=-=-=-=-=-=-=-=  File Selection Methods - INSTANT UPDATES
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

        ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
        emit(state.copyWith(selectedFiles: updatedFiles));
        log('Selected ${files.length} files');
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(errorMessage: 'Error selecting files: $e'));
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
        log('Selected image from gallery: ${image.path}');
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(errorMessage: 'Error selecting image: $e'));
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
        emit(state.copyWith(errorMessage: 'Error capturing image: $e'));
      }
    }
  }

  void _addSelectedFile(File file) {
    if (_isDisposed) return;

    final currentFiles = state.selectedFiles ?? [];
    final updatedFiles = [...currentFiles, file];

    ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  void removeSelectedFile(int index) {
    if (_isDisposed) return;

    if (state.selectedFiles != null && index < state.selectedFiles!.length) {
      final updatedFiles = List<File>.from(state.selectedFiles!);
      updatedFiles.removeAt(index);

      ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
      emit(state.copyWith(selectedFiles: updatedFiles));
      log('Removed file at index $index');
    }
  }

  Future<void> clearOldFileCache() async {
    log('🧹 Clearing old file cache...');

    // Clear cubit's file cache
    _fileUrls.clear();
    _fileTypes.clear();
    _loadingFiles.clear();
    _fileCacheTimestamps.clear();
    _failedLoads.clear();

    // Clear MediaCache
    MediaCache.clearAll(); // You'll need to add this method to MediaCache

    log('✅ Old cache cleared');
  }

  void clearSelectedFiles() {
    if (_isDisposed) return;

    ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
    emit(state.copyWith(selectedFiles: [], isChatEntry: ApiFetchStatus.idle));
    log('Cleared all selected files');
  }

  ///=-=-=-=-=-=-=-=-=  Legacy method for backward compatibility
  Future<void> loadMediaFilesForEntries(List<Entry> entries) async {
    _loadMediaInBackground(entries);
  }

  ///=-=-=-=-=-=-=-=-=  Cache Management
  bool _isFileLoadedAndValid(String mediaId) {
    if (!_fileUrls.containsKey(mediaId)) return false;

    final timestamp = _fileCacheTimestamps[mediaId];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  ///=-=-=-=-=-=-=-=-=  Public getters for UI
  String? getFileUrl(String mediaId) => _fileUrls[mediaId];
  String? getFileType(String mediaId) => _fileTypes[mediaId];
  bool isFileLoading(String mediaId) => _loadingFiles[mediaId] == true;
  bool isFileLoaded(String mediaId) => _isFileLoadedAndValid(mediaId);

  ///=-=-=-=-=-=-=-=-=  Tab Management - INSTANT UPDATES
  Future<void> selectedTab(String value) async {
    if (_isDisposed) return;

    ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
    emit(state.copyWith(selectedTab: value));

    ///=-=-=-=-=-=-=-=-=  Filter immediately without delay
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

    ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
    emit(state.copyWith(chatList: filteredChats, selectedTab: selectedTab));
  }

  ///=-=-=-=-=-=-=-=-=  Utility Methods
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> initStateClear() async {
    if (_isDisposed) return;

    ///=-=-=-=-=-=-=-=-=  INSTANT UI UPDATE
    emit(state.copyWith(isArrow: false, isChatEntry: ApiFetchStatus.idle));
  }

  ///=-=-=-=-=-=-=-=-=  Cache clearing methods
  void clearChatCache() {
    _chatCache.clear();
    _chatCacheTimestamps.clear();
    log('🗑️ Cleared chat cache');
  }

  void clearChatCacheForId(int chatId) {
    _chatCache.remove(chatId);
    _chatCacheTimestamps.remove(chatId);
    log('🗑️ Cleared cache for chat $chatId');
  }

  Future<void> viewMediaFile(ChatMedias media) async {
    if (_isDisposed || media.id == null || media.mediaUrl == null) return;

    final mediaId = media.id.toString();

    // Check if already loaded
    if (!isFileLoaded(mediaId)) {
      emit(state.copyWith(isLoadingMedia: true));
      await loadMediaFile(media);
      emit(state.copyWith(isLoadingMedia: false));
    }

    final fileUrl = getFileUrl(mediaId);
    final fileType = getFileType(mediaId);

    if (fileUrl != null && fileType != null) {
      // Create file data map for viewing
      final fileData = {
        'type': fileType,
        'data': fileUrl,
        'mimeType': _getMimeTypeForFile(fileType),
      };

      // Emit state for UI to handle viewing
      emit(state.copyWith(viewingFile: fileData));
      log('📱 Viewing file: $mediaId, type: $fileType');
    } else {
      emit(
        state.copyWith(
          errorMessage: 'Failed to load file for viewing',
          isLoadingMedia: false,
        ),
      );
    }
  }

  String _getMimeTypeForFile(String fileType) {
    switch (fileType) {
      case 'image':
        return 'image/jpeg'; // You might want to store actual mime type
      case 'audio':
        return 'audio/mpeg';
      case 'document':
        return 'application/pdf';
      case 'video':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Future<void> close() {
    log('Closing ChatCubit...');
    _isDisposed = true;

    _recordingTimer?.cancel();
    _batchUpdateTimer?.cancel();
    _audioRecorder.dispose();

    // Clean up caches
    _fileUrls.clear();
    _fileTypes.clear();
    _loadingFiles.clear();
    _fileCacheTimestamps.clear();
    _failedLoads.clear();
    _chatCache.clear();
    _chatCacheTimestamps.clear();

    return super.close();
  }
}

// Initial state class

// Helper function for fire-and-forget futures
void unawaited(Future<void> future) {
  future.catchError((error) {
    log('Unawaited future error: $error');
  });
}
