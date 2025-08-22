import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
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

    _batchUpdateTimer = Timer(_batchDelay, () {
      if (_hasPendingUpdates && !_isDisposed) {
        emit(
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
    emit(state.copyWith(isArrow: !state.isArrow));
  }

  void resetState() {
    emit(state.copyWith(isArrow: false));
  }

  // void resetChatState() {
  //   if (_isDisposed) return;

  //   log('🔄 Resetting chat state');

  //   emit(
  //     state.copyWith(
  //       isChatEntry: ApiFetchStatus.idle, // ✅ Set to idle, not loading
  //       chatEntry: null,
  //       errorMessage: null,
  //       isArrow: false,
  //     ),
  //   );
  // }

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

  // ✅ CRITICAL FIXES for UI updates
  // 🔧 CRITICAL FIX: Enhanced _handleNewEntries in ChatCubit

  void _handleNewEntries(List<Entry> newEntries) {
    log(
      '📨 🎯 SignalR: Received ${newEntries.length} new entries from ReceiveMessage',
    );
    log('📊 Current chat ID: $_currentChatId');
    log('📊 Current chat state: ${state.isChatEntry}');
    log('📊 Has chatEntry: ${state.chatEntry != null}');

    if (_isDisposed) {
      log('⚠️ Cubit is disposed, ignoring new entries');
      return;
    }

    if (_currentChatId == null) {
      log('⚠️ No current chat ID set');
      return;
    }

    // ✅ DEBUG: Log incoming entries in detail
    for (var i = 0; i < newEntries.length; i++) {
      final entry = newEntries[i];
      log(
        '🔍 Entry $i: ID=${entry.id}, ChatID=${entry.chatId}, Content="${entry.content}", Sender=${entry.senderId}',
      );
    }

    if (state.chatEntry == null) {
      log('⚠️ No chat entry state - requesting fresh data');
      getChatEntry(chatId: _currentChatId);
      return;
    }

    final currentChatIdStr = _currentChatId.toString();
    final relevantEntries = newEntries.where((entry) {
      final entryChatId = entry.chatId?.toString() ?? '';
      final isRelevant = entryChatId == currentChatIdStr;
      log(
        '🔍 Entry ${entry.id}: chatId="$entryChatId" vs current="$currentChatIdStr" -> $isRelevant',
      );
      return isRelevant;
    }).toList();

    log('📊 Relevant entries for current chat: ${relevantEntries.length}');

    if (relevantEntries.isEmpty) {
      log('ℹ️ No relevant entries for current chat $_currentChatId');
      return;
    }

    // ✅ CRITICAL: Get current entries and check for duplicates
    final currentEntries = List<Entry>.from(state.chatEntry!.entries ?? []);
    log('📊 Current entries count: ${currentEntries.length}');

    final existingIds = currentEntries
        .map((e) => e.id?.toString())
        .where((id) => id != null)
        .toSet();

    log('📊 Existing entry IDs (last 5): ${existingIds.take(5).toList()}');

    final filteredNewEntries = relevantEntries.where((entry) {
      final entryId = entry.id?.toString();
      final isNew = entryId != null && !existingIds.contains(entryId);
      log('🔍 Entry ${entry.id}: exists=${!isNew}, will add=$isNew');
      return isNew;
    }).toList();

    log(
      '📊 New entries after filtering duplicates: ${filteredNewEntries.length}',
    );

    if (filteredNewEntries.isEmpty) {
      log('ℹ️ No new entries to add (all already exist)');
      return;
    }

    try {
      // ✅ CRITICAL: Create completely new collections for immutability
      final updatedEntries = <Entry>[...currentEntries, ...filteredNewEntries];

      log('📊 Total entries after update: ${updatedEntries.length}');
      log(
        '📊 Last entry will be: ID=${filteredNewEntries.last.id}, Content="${filteredNewEntries.last.content}"',
      );

      // ✅ CRITICAL: Use copyWith instead of manual state creation
      final updatedChatEntry = state.chatEntry!.copyWith(
        entries: updatedEntries,
      );

      // Update cache
      _chatCache[_currentChatId!] = updatedChatEntry;
      _chatCacheTimestamps[_currentChatId!] = DateTime.now();

      log(
        '🚀 🎯 EMITTING STATE UPDATE with ${filteredNewEntries.length} new entries',
      );
      log('📊 Previous state hash: ${state.hashCode}');
      log('📊 Previous entries count: ${currentEntries.length}');
      log('📊 New entries count: ${updatedEntries.length}');

      // ✅ CRITICAL: Use state.copyWith() instead of manual ChatState creation
      emit(
        state.copyWith(
          chatEntry: updatedChatEntry,
          isChatEntry: ApiFetchStatus.success,
          errorMessage: null,
        ),
      );

      // ✅ Load media for new entries AFTER emit
      _loadMediaForNewEntries(filteredNewEntries);

      log('✅ 🎯 STATE EMITTED SUCCESSFULLY from ReceiveMessage');

      // ✅ Debug verification with delay
      Future.delayed(Duration(milliseconds: 200), () {
        if (!_isDisposed) {
          log('🔍 Post-emit verification:');
          log('  - Current state entries: ${state.chatEntry?.entries?.length}');
          log('  - Current state status: ${state.isChatEntry}');
          log('  - Current state hash: ${state.hashCode}');

          if (state.chatEntry?.entries?.isNotEmpty == true) {
            final lastEntry = state.chatEntry!.entries!.last;
            log(
              '  - Last entry: ID=${lastEntry.id}, Content="${lastEntry.content}"',
            );
          }
        }
      });
    } catch (e) {
      log('❌ Error updating state with new entries from ReceiveMessage: $e');
      log('❌ Stack trace: ${StackTrace.current}');
      emit(state.copyWith(errorMessage: 'Failed to update chat: $e'));
    }
  }

  void _loadMediaForNewEntries(List<Entry> newEntries) {
    log('📎 Loading media for ${newEntries.length} new SignalR entries...');

    final entriesWithMedia = newEntries
        .where((entry) => entry.chatMedias?.isNotEmpty == true)
        .toList();

    if (entriesWithMedia.isEmpty) {
      log('📎 No media files in new entries');
      return;
    }

    log('📎 Found ${entriesWithMedia.length} entries with media files');

    // ✅ Load media files immediately and update UI
    for (var entry in entriesWithMedia) {
      if (entry.chatMedias?.isNotEmpty == true) {
        log(
          '📎 Loading ${entry.chatMedias!.length} media files for entry ${entry.id}',
        );

        for (var media in entry.chatMedias!) {
          if (media.id != null && media.mediaUrl != null) {
            final mediaId = media.id.toString();
            log('📎 Starting immediate load for media: $mediaId');

            // ✅ Load synchronously to ensure immediate availability
            _loadSingleMediaFileImmediate(media)
                .then((_) {
                  log('📎 Completed loading media: $mediaId');
                  // ✅ Trigger UI update after each media loads
                  _scheduleMediaUpdate();
                })
                .catchError((e) {
                  log('❌ Failed to load media $mediaId: $e');
                });
          }
        }
      }
    }
  }

  Future<void> _loadSingleMediaFileImmediate(ChatMedias media) async {
    if (_isDisposed || media.id == null || media.mediaUrl == null) return;

    final String mediaId = media.id.toString();

    // Skip if already loaded or currently loading
    if (_loadingFiles[mediaId] == true || _isFileLoadedAndValid(mediaId)) {
      log('📎 Media $mediaId already loaded/loading, skipping');
      return;
    }

    if (_failedLoads.contains(mediaId)) {
      log('📎 Media $mediaId previously failed, retrying...');
      _failedLoads.remove(mediaId); // Give it another chance
    }

    _loadingFiles[mediaId] = true;
    log('📎 🔄 Loading media file: $mediaId from ${media.mediaUrl}');

    try {
      final fileData = await _chatRepositories.getFileFromApi(media.mediaUrl!);

      if (_isDisposed) return;

      if (fileData['data'] != null && fileData['data'].toString().isNotEmpty) {
        _fileUrls[mediaId] = fileData['data'] ?? '';
        _fileTypes[mediaId] = fileData['type'] ?? 'unknown';
        _fileCacheTimestamps[mediaId] = DateTime.now();
        _failedLoads.remove(mediaId);

        log('✅ Successfully loaded media: $mediaId, type: ${fileData['type']}');
        log('📊 File URL length: ${(_fileUrls[mediaId] ?? '').length}');

        // ✅ Immediately notify UI about the loaded media
        emit(
          state.copyWith(
            fileUrls: Map<String, String>.from(_fileUrls),
            fileTypes: Map<String, String>.from(_fileTypes),
          ),
        );
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

  // ✅ ENHANCED: Better file checking with debug info
  bool _isFileLoadedAndValid(String mediaId) {
    final hasUrl = _fileUrls.containsKey(mediaId);
    final timestamp = _fileCacheTimestamps[mediaId];
    final isValid =
        timestamp != null &&
        DateTime.now().difference(timestamp) < _cacheExpiration;

    log('📎 File $mediaId: hasUrl=$hasUrl, isValid=$isValid');

    return hasUrl && isValid;
  }

  void debugMediaLoadingStatus() {
    log('🔍 ===== Media Loading Debug =====');
    log('📎 Total cached URLs: ${_fileUrls.length}');
    log('📎 Total cached types: ${_fileTypes.length}');
    log(
      '📎 Currently loading: ${_loadingFiles.values.where((loading) => loading).length}',
    );
    log('📎 Failed loads: ${_failedLoads.length}');

    if (state.chatEntry?.entries != null) {
      final entriesWithMedia = state.chatEntry!.entries!
          .where((entry) => entry.chatMedias?.isNotEmpty == true)
          .toList();
      log('📎 Entries with media: ${entriesWithMedia.length}');

      for (var entry in entriesWithMedia) {
        for (var media in entry.chatMedias ?? []) {
          final mediaId = media.id?.toString() ?? 'unknown';
          final isLoaded = _isFileLoadedAndValid(mediaId);
          final isLoading = _loadingFiles[mediaId] == true;
          final hasFailed = _failedLoads.contains(mediaId);

          log(
            '📎 Media $mediaId: loaded=$isLoaded, loading=$isLoading, failed=$hasFailed',
          );
        }
      }
    }
    log('🔍 ==============================');
  }

  // ✅ FIXED: Enhanced event handlers with better chat ID matching
  void _handleNewChatEntry(ChatEntryResponse newChatEntry) {
    log(
      '📨 SignalR: Received new chat entry with ${newChatEntry.entries?.length ?? 0} entries',
    );

    if (_isDisposed) {
      log('⚠️ Cubit is disposed, ignoring chat entry');
      return;
    }

    if (_currentChatId == null) {
      log('⚠️ No current chat ID set');
      return;
    }

    // ✅ Extract entries and handle them
    final entries = newChatEntry.entries ?? [];
    if (entries.isNotEmpty) {
      log('🔄 Processing ${entries.length} entries from chat entry response');
      _handleNewEntries(entries);
    } else {
      log('ℹ️ Chat entry response has no entries');
    }
  }

  void _handleEntryUpdate(Entry updatedEntry) {
    log('📝 SignalR: Entry updated - ${updatedEntry.id}');

    if (_isDisposed || _currentChatId == null || state.chatEntry == null) {
      log('⚠️ Cannot handle entry update - invalid state');
      return;
    }

    // ✅ FIXED: Better chat ID comparison
    final entryChatId = updatedEntry.chatId?.toString();
    final currentChatId = _currentChatId.toString();

    if (entryChatId != currentChatId) {
      log(
        'ℹ️ Entry update not for current chat: $entryChatId vs $currentChatId',
      );
      return;
    }

    try {
      final currentEntries = List<Entry>.from(state.chatEntry!.entries ?? []);
      bool wasUpdated = false;

      final updatedEntries = currentEntries.map((entry) {
        if (entry.id?.toString() == updatedEntry.id?.toString()) {
          wasUpdated = true;
          log('✅ Found and updating entry ${entry.id}');
          return updatedEntry;
        }
        return entry;
      }).toList();

      if (!wasUpdated) {
        log('⚠️ Entry ${updatedEntry.id} not found in current entries');
        return;
      }

      final updatedChatEntry = state.chatEntry!.copyWith(
        entries: updatedEntries,
      );

      // Update cache
      _chatCache[_currentChatId!] = updatedChatEntry;
      _chatCacheTimestamps[_currentChatId!] = DateTime.now();

      log('🚀 EMITTING ENTRY UPDATE for ${updatedEntry.id}');

      emit(
        state.copyWith(
          chatEntry: updatedChatEntry,
          isChatEntry: ApiFetchStatus.success,
        ),
      );

      log('✅ Entry ${updatedEntry.id} updated successfully');
    } catch (e) {
      log('❌ Error updating entry: $e');
    }
  }

  // ✅ FIXED: Better entry deletion handler
  void _handleEntryDeletion(String entryId) {
    log('🗑️ SignalR: Entry deleted - $entryId');

    if (_isDisposed || _currentChatId == null || state.chatEntry == null) {
      log('⚠️ Cannot handle entry deletion - invalid state');
      return;
    }

    try {
      final currentEntries = List<Entry>.from(state.chatEntry!.entries ?? []);
      final originalCount = currentEntries.length;

      final filteredEntries = currentEntries
          .where((entry) => entry.id?.toString() != entryId)
          .toList();

      if (filteredEntries.length == originalCount) {
        log('ℹ️ Entry $entryId not found in current chat');
        return;
      }

      final updatedChatEntry = state.chatEntry!.copyWith(
        entries: filteredEntries,
      );

      // Update cache
      _chatCache[_currentChatId!] = updatedChatEntry;
      _chatCacheTimestamps[_currentChatId!] = DateTime.now();

      log('🚀 EMITTING ENTRY DELETION for $entryId');

      emit(
        state.copyWith(
          chatEntry: updatedChatEntry,
          isChatEntry: ApiFetchStatus.success,
        ),
      );

      log('✅ Entry $entryId deleted successfully');
    } catch (e) {
      log('❌ Error deleting entry: $e');
    }
  }

  bool _isLoadingChat = false;
  Completer<void>? _chatLoadCompleter;
  Timer? _chatLoadTimeoutTimer;
  static const Duration _chatLoadTimeout = Duration(seconds: 30);
  Future<void> getChatEntry({int? chatId}) async {
    final currentChatId = chatId ?? 0;
    log('📱 Getting chat entry for chatId: $currentChatId');

    // CRITICAL FIX: Handle concurrent chat loading attempts
    if (_isLoadingChat) {
      log('⏳ Chat already loading, waiting for completion...');

      if (_chatLoadCompleter != null) {
        try {
          await _chatLoadCompleter!.future.timeout(
            _chatLoadTimeout,
            onTimeout: () {
              log('⏰ Chat load wait timed out, forcing reset');
              _resetChatLoadState();
              throw TimeoutException(
                'Chat load wait timeout',
                _chatLoadTimeout,
              );
            },
          );
          return;
        } catch (e) {
          log('❌ Error waiting for chat load: $e');
          _resetChatLoadState();
          // Continue with new attempt
        }
      }
    }

    // Start new chat loading attempt
    _isLoadingChat = true;
    _chatLoadCompleter = Completer<void>();

    // Set up timeout
    _chatLoadTimeoutTimer?.cancel();
    _chatLoadTimeoutTimer = Timer(_chatLoadTimeout, () {
      if (_isLoadingChat) {
        log('⏰ Chat loading timed out');
        _handleChatLoadTimeout();
      }
    });

    try {
      await _performChatLoad(currentChatId);
    } catch (e) {
      log('❌ Error in getChatEntry: $e');
      _handleChatLoadFailure(e);
      rethrow;
    } finally {
      _chatLoadTimeoutTimer?.cancel();
    }
  }

  // FIXED: Actual chat loading logic
  Future<void> _performChatLoad(int currentChatId) async {
    final previousChatId = _currentChatId;
    _currentChatId = currentChatId;

    // Always clear state when switching chats or coming back
    emit(
      state.copyWith(
        isChatEntry: ApiFetchStatus.loading,
        chatEntry: null,
        errorMessage: null,
      ),
    );

    if (_isDisposed) {
      _completeChatLoad();
      return;
    }

    try {
      // Handle different scenarios
      if (previousChatId != null && previousChatId != currentChatId) {
        log('🔄 Switching chats: $previousChatId -> $currentChatId');
        await _handleChatSwitch(previousChatId, currentChatId);
      } else if (previousChatId == currentChatId) {
        log('🔄 Returning to same chat: $currentChatId (comeback scenario)');
        await _handleChatComeback(currentChatId);
      } else {
        log('🔄 First time opening chat: $currentChatId');
        await _handleFirstTimeChat(currentChatId);
      }

      // FIXED: Non-blocking SignalR connection
      _establishSignalRConnectionAsync(currentChatId);

      // Check cache validity
      final shouldUseCache = _shouldUseCachedData(
        currentChatId,
        previousChatId,
      );

      if (shouldUseCache) {
        await _loadFromCache(currentChatId);
      } else {
        await _loadFromAPI(currentChatId);
      }

      _completeChatLoad();
      log('✅ Chat entry loaded successfully for chat $currentChatId');
    } catch (e) {
      log('❌ Error in chat loading: $e');
      _handleChatLoadFailure(e);
    }
  }

  // FIXED: Non-blocking SignalR connection (async)
  void _establishSignalRConnectionAsync(int chatId) {
    log('🔗 Starting async SignalR connection for chat: $chatId');

    // Don't await - let it run in background
    unawaited(_connectSignalRInBackground(chatId));
  }

  // FIXED: Background SignalR connection with retry
  Future<void> _connectSignalRInBackground(int chatId) async {
    try {
      log('🔄 Background SignalR connection attempt for chat: $chatId');

      // Try to connect with timeout
      await _signalRService.initializeConnection().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          log('⏰ SignalR connection timed out in background');
          throw TimeoutException('SignalR timeout', Duration(seconds: 15));
        },
      );

      if (_signalRService.isConnected) {
        log('✅ Background SignalR connection successful');
        await _signalRService.joinChatGroup(chatId.toString());

        // Clear any connection error messages
        if (state.errorMessage?.contains('Connection') == true) {
          emit(state.copyWith(errorMessage: null));
        }
      }
    } catch (e) {
      log('⚠️ Background SignalR connection failed: $e');

      // Emit warning but don't block UI
      if (!_isDisposed) {
        emit(
          state.copyWith(
            errorMessage: 'Real-time updates unavailable. Refresh to retry.',
          ),
        );
      }

      // Schedule retry after delay
      Timer(Duration(seconds: 10), () {
        if (!_isDisposed && _currentChatId == chatId) {
          log('🔄 Retrying SignalR connection...');
          _connectSignalRInBackground(chatId);
        }
      });
    }
  }

  // Helper methods for chat load state management
  void _completeChatLoad() {
    _isLoadingChat = false;
    if (_chatLoadCompleter != null && !_chatLoadCompleter!.isCompleted) {
      _chatLoadCompleter!.complete();
    }
    _chatLoadCompleter = null;
  }

  void _handleChatLoadTimeout() {
    log('⏰ Chat load timeout reached');
    _handleChatLoadFailure(
      TimeoutException('Chat load timeout', _chatLoadTimeout),
    );
  }

  void _handleChatLoadFailure(dynamic error) {
    log('❌ Handling chat load failure: $error');

    _chatLoadTimeoutTimer?.cancel();

    if (_chatLoadCompleter != null && !_chatLoadCompleter!.isCompleted) {
      _chatLoadCompleter!.completeError(error);
    }

    _isLoadingChat = false;
    _chatLoadCompleter = null;

    if (!_isDisposed) {
      emit(
        state.copyWith(
          isChatEntry: ApiFetchStatus.failed,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _resetChatLoadState() {
    log('🔄 Resetting chat load state');

    _chatLoadTimeoutTimer?.cancel();

    if (_chatLoadCompleter != null && !_chatLoadCompleter!.isCompleted) {
      _chatLoadCompleter!.completeError(Exception('Chat load state reset'));
    }

    _isLoadingChat = false;
    _chatLoadCompleter = null;
  }

  // FIXED: Enhanced resetChatState for navigation
  void resetChatState() {
    if (_isDisposed) return;

    log('🔄 Resetting chat state for navigation');

    // Cancel any ongoing operations
    _chatLoadTimeoutTimer?.cancel();
    _batchUpdateTimer?.cancel();

    // Reset loading states
    _resetChatLoadState();
    _hasPendingUpdates = false;

    emit(
      state.copyWith(
        isChatEntry: ApiFetchStatus.idle,
        chatEntry: null,
        errorMessage: null,
        isArrow: false,
      ),
    );
  }

  // FIXED: Enhanced refreshAfterComeback with proper state reset
  Future<void> refreshAfterComeback() async {
    log('🔄 Refreshing chat after comeback...');

    if (_currentChatId == null) {
      log('⚠️ No current chat ID for refresh');
      return;
    }

    try {
      // Reset all state
      _resetChatLoadState();
      _chatCache.clear();
      _chatCacheTimestamps.clear();
      _isFirstLoad = true;
      _hasPendingUpdates = false;
      _batchUpdateTimer?.cancel();

      // Force SignalR reset
      await _signalRService.forceReset();

      // Reload chat data
      await getChatEntry(chatId: _currentChatId);

      log('✅ Successfully refreshed after comeback');
    } catch (e) {
      log('❌ Error during comeback refresh: $e');
      emit(
        state.copyWith(
          isChatEntry: ApiFetchStatus.failed,
          errorMessage: 'Failed to refresh chat: $e',
        ),
      );
    }
  }

  // Add emergency reset method for debugging
  Future<void> emergencyReset() async {
    log('🚨 Emergency reset triggered');

    _resetChatLoadState();
    await _signalRService.forceReset();

    _currentChatId = null;
    _chatCache.clear();
    _chatCacheTimestamps.clear();

    emit(InitialChatState());

    log('✅ Emergency reset complete');
  }
  // // Enhanced getChatEntry method with proper SignalR handling
  // Future<void> getChatEntry({int? chatId}) async {
  //   final currentChatId = chatId ?? 0;
  //   log('📱 🔄 Getting chat entry for chatId: $currentChatId');

  //   final previousChatId = _currentChatId;
  //   _currentChatId = currentChatId;

  //   // Always clear state when switching chats or coming back
  //   emit(
  //     state.copyWith(
  //       isChatEntry: ApiFetchStatus.loading,
  //       chatEntry: null,
  //       errorMessage: null,
  //     ),
  //   );

  //   if (_isDisposed) return;

  //   try {
  //     // Handle different scenarios
  //     if (previousChatId != null && previousChatId != currentChatId) {
  //       log('🔄 Switching chats: $previousChatId -> $currentChatId');
  //       await _handleChatSwitch(previousChatId, currentChatId);
  //     } else if (previousChatId == currentChatId) {
  //       log('🔄 Returning to same chat: $currentChatId (comeback scenario)');
  //       await _handleChatComeback(currentChatId);
  //     } else {
  //       log('🔄 First time opening chat: $currentChatId');
  //       await _handleFirstTimeChat(currentChatId);
  //     }

  //     // Establish proper SignalR connection BEFORE loading data
  //     final signalRConnected = await _establishSignalRConnection(currentChatId);
  //     if (!signalRConnected) {
  //       log('⚠️ SignalR connection failed, but continuing with API call...');
  //     }

  //     // Check cache validity
  //     final shouldUseCache = _shouldUseCachedData(
  //       currentChatId,
  //       previousChatId,
  //     );

  //     if (shouldUseCache) {
  //       await _loadFromCache(currentChatId);
  //     } else {
  //       await _loadFromAPI(currentChatId);
  //     }

  //     // Final sync with SignalR
  //     await _finalizeSignalRConnection(currentChatId);
  //   } catch (e) {
  //     log('❌ Error in getChatEntry for chat $currentChatId: $e');
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

  // Enhanced SignalR connection establishment
  Future<bool> _establishSignalRConnection(int chatId) async {
    log('🔗 Establishing SignalR connection for chat: $chatId');

    try {
      // Step 1: Check current connection status
      bool isConnected = _signalRService.isConnected;
      log(
        '📡 Current SignalR status: ${isConnected ? "Connected" : "Disconnected"}',
      );

      // Step 2: If not connected, attempt connection with retry logic
      if (!isConnected) {
        isConnected = await _connectSignalRWithRetry();
      }

      if (!isConnected) {
        log('❌ Failed to establish SignalR connection after retries');
        return false;
      }

      // Step 3: Leave previous group and join new group
      await _switchSignalRGroups(chatId);

      return true;
    } catch (e) {
      log('❌ Error establishing SignalR connection: $e');
      return false;
    }
  }

  // SignalR connection with retry logic
  Future<bool> _connectSignalRWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('🔄 SignalR connection attempt $attempt/$maxRetries');

        // Disconnect first if partially connected
        if (_signalRService.isConnected) {
          await _signalRService.disconnect();
          await Future.delayed(Duration(milliseconds: 500));
        }

        // Attempt fresh connection
        await _signalRService.initializeConnection();

        // Wait a bit and verify connection
        await Future.delayed(Duration(milliseconds: 1000));

        if (_signalRService.isConnected) {
          log('✅ SignalR connected successfully on attempt $attempt');
          return true;
        } else {
          log('⚠️ SignalR connection attempt $attempt failed - not connected');
        }
      } catch (e) {
        log('❌ SignalR connection attempt $attempt failed: $e');
      }

      // Wait before retry (exponential backoff)
      if (attempt < maxRetries) {
        final delayMs = 1000 * attempt; // 1s, 2s, 3s
        log('⏳ Waiting ${delayMs}ms before retry...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    log('❌ All SignalR connection attempts failed');
    return false;
  }

  // Enhanced group switching
  Future<void> _switchSignalRGroups(int newChatId) async {
    try {
      log('🔄 Switching to SignalR group for chat: $newChatId');

      // Leave all previous groups (if any)
      if (_previousSignalRChatId != null &&
          _previousSignalRChatId != newChatId) {
        try {
          await _signalRService.leaveChatGroup(
            _previousSignalRChatId.toString(),
          );
          log('✅ Left previous SignalR group: $_previousSignalRChatId');
        } catch (e) {
          log('⚠️ Error leaving previous group: $e');
        }
      }

      // Join new group
      await _signalRService.joinChatGroup(newChatId.toString());
      log('✅ Joined SignalR group: $newChatId');

      _previousSignalRChatId = newChatId;
    } catch (e) {
      log('❌ Error switching SignalR groups: $e');
      rethrow;
    }
  }

  // Check if we should use cached data
  bool _shouldUseCachedData(int chatId, int? previousChatId) {
    final cachedData = _chatCache[chatId];
    final cacheTimestamp = _chatCacheTimestamps[chatId];
    final isCacheValid =
        cachedData != null &&
        cacheTimestamp != null &&
        DateTime.now().difference(cacheTimestamp) < _chatCacheExpiration;

    // For comeback scenario or fresh data needs, skip cache
    final isComeback = previousChatId == chatId;
    final shouldSkipCache = isComeback || !isCacheValid;

    return isCacheValid && !shouldSkipCache;
  }

  // Load from cache
  Future<void> _loadFromCache(int chatId) async {
    final cachedData = _chatCache[chatId]!;
    log('💾 Using cached data for chat $chatId');

    await Future.delayed(const Duration(milliseconds: 200));

    if (_isDisposed) return;
    final data = state.copyWith(
      chatList: state.chatList?.map((e) {
        if (e.chatId == chatId) {
          return e.copyWith(unreadCount: 0);
        }
        return e;
      }).toList(),
    );
    emit(
      state.copyWith(
        chatEntry: cachedData,
        chatList: data.chatList,
        isChatEntry: ApiFetchStatus.success,
      ),
    );

    if (cachedData.entries?.isNotEmpty == true) {
      _loadMediaInBackground(cachedData.entries!);
    }
  }

  // Load from API
  Future<void> _loadFromAPI(int chatId) async {
    log('🌐 Making API call for chat $chatId (fresh data needed)');

    final res = await _chatRepositories.chatEntry(chatId);

    if (_isDisposed) return;

    if (res.data != null) {
      _chatCache[chatId] = res.data!;
      _chatCacheTimestamps[chatId] = DateTime.now();

      log('✅ Successfully loaded chat entry for chat $chatId');
      log('📊 Loaded ${res.data!.entries?.length ?? 0} entries');
      final data = state.copyWith(
        chatList: state.chatList?.map((e) {
          if (e.chatId == chatId) {
            return e.copyWith(unreadCount: 0);
          }
          return e;
        }).toList(),
      );
      emit(
        state.copyWith(
          chatList: data.chatList,
          chatEntry: res.data,
          isChatEntry: ApiFetchStatus.success,
        ),
      );

      if (res.data?.entries != null && res.data!.entries!.isNotEmpty) {
        _loadMediaInBackground(res.data!.entries!);
      }
    } else {
      log('⚠️ No data received for chat $chatId');
      emit(
        state.copyWith(isChatEntry: ApiFetchStatus.success, chatEntry: null),
      );
    }
  }

  // Finalize SignalR connection after loading data
  Future<void> _finalizeSignalRConnection(int chatId) async {
    if (!_signalRService.isConnected) {
      log('⚠️ SignalR not connected during finalization');
      return;
    }

    try {
      log('🔄 Finalizing SignalR connection for chat: $chatId');

      // Wait for UI to settle
      await Future.delayed(Duration(milliseconds: 500));

      // Send a ping to verify connection
      // await _signalRService.sendPing();

      // Request any missed messages
      await _requestMissedMessages(chatId);

      log('✅ SignalR connection finalized for chat: $chatId');
    } catch (e) {
      log('⚠️ Error during SignalR finalization: $e');
    }
  }

  // Request missed messages
  Future<void> _requestMissedMessages(int chatId) async {
    try {
      // Get timestamp of last message we have
      final lastMessage = state.chatEntry?.entries?.lastOrNull;
      final lastTimestamp = lastMessage?.createdAt;

      if (lastTimestamp != null) {
        log('📡 Requesting missed messages since: $lastTimestamp');
        // Implement this method in your SignalR service
        await _signalRService.requestMissedMessages(
          chatId.toString(),
          lastTimestamp,
        );
      }
    } catch (e) {
      log('⚠️ Could not request missed messages: $e');
    }
  }

  // Enhanced chat switch handling
  Future<void> _handleChatSwitch(int previousChatId, int currentChatId) async {
    log('🔄 Handling chat switch: $previousChatId -> $currentChatId');

    // Clear any pending updates
    _batchUpdateTimer?.cancel();
    _hasPendingUpdates = false;

    // Reset state flags
    _isFirstLoad = true;
  }

  // Enhanced comeback handling
  Future<void> _handleChatComeback(int chatId) async {
    log('🔄 Handling comeback to chat: $chatId');

    // Clear any stale state
    _batchUpdateTimer?.cancel();
    _hasPendingUpdates = false;

    // Force cache invalidation for comeback scenario
    _chatCacheTimestamps.remove(chatId);

    // Reset connection state
    _isFirstLoad = true;

    log('🗑️ Cleared cache and reset state for comeback scenario');
  }

  // First time chat handling
  Future<void> _handleFirstTimeChat(int chatId) async {
    log('🔄 Handling first time chat: $chatId');
    _isFirstLoad = true;
  }

  int? _previousSignalRChatId;
  bool _isFirstLoad = true;

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
    }
  }

  ///=-=-=-=-=-=-=-=-=  Method to refresh chat data (force refresh)
  Future<void> refreshChatEntry({int? chatId}) async {
    final currentChatId = chatId ?? 0;
    log('🔄 Force refreshing chat entry for chatId: $currentChatId');

    ///=-=-=-=-=-=-=-=-=  Clear cache for this chat
    _chatCache.remove(currentChatId);
    _chatCacheTimestamps.remove(currentChatId);

    ///=-=-=-=-=-=-=-=-=  Show loading
    emit(state.copyWith(isChatEntry: ApiFetchStatus.loading));

    ///=-=-=-=-=-=-=-=-=  Fetch fresh data
    await getChatEntry(chatId: chatId);
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
                type: 'CN',
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

  //=============== Enhanced Reply with INSTANT UI Updates
  Future<void> sendReplyMessage({
    required String replyMessage,
    required Entry originalMessage,
    required AddChatEntryRequest baseRequest,
  }) async {
    if (replyMessage.trim().isEmpty) return;

    final user = await AuthUtils.instance.readUserData();
    final userId = int.tryParse(user?.result?.userId.toString() ?? '') ?? 0;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempReplyMessage = Entry(
      id: tempId,
      content: replyMessage.trim(),
      messageType: 'text',
      senderId: userId,
      type: 'N',
      typeValue: 0,
      createdAt: DateTime.now().toIso8601String(),
      chatId: baseRequest.chatId,
      otherDetails1: jsonEncode([
        {
          // "InitialChatEntryId": originalMessage.id.toString(),
          "ReplayChatEntryId": originalMessage.id.toString(),
        },
      ]),
    );

    final currentEntries = state.chatEntry?.entries ?? <Entry>[];
    final updatedEntries = List<Entry>.from(currentEntries)
      ..add(tempReplyMessage);
    emit(
      state.copyWith(
        chatEntry:
            state.chatEntry?.copyWith(entries: updatedEntries) ??
            ChatEntryResponse(entries: updatedEntries),
        selectedFiles: [],
        replyingTo: null,
        isReplying: false,
      ),
    );

    try {
      // 4️⃣ Prepare backend request
      final replyRequest = AddChatEntryRequest(
        chatId: baseRequest.chatId,
        senderId: userId,
        type: 'N',
        typeValue: 0,
        messageType: 'text',
        content: replyMessage.trim(),
        source: 'Mobile',
        // ✅ Include reply details for backend
        otherDetails1: jsonEncode([
          {
            // "InitialChatEntryId": originalMessage.id.toString(),
            "ReplayChatEntryId": originalMessage.id.toString(),
          },
        ]),
      );

      // 5️⃣ Send to backend
      final res = await _chatRepositories.addChatEntry(
        req: replyRequest,
        files: [],
      );

      if (_isDisposed) return;

      if (res.data != null) {
        // 6️⃣ Replace temp message with server response
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
          otherDetails1: res.data!.otherDetails1, // Server reply data
        );

        final finalEntries = updatedEntries.map((entry) {
          return entry.id == tempId ? serverEntry : entry;
        }).toList();

        emit(
          state.copyWith(
            chatEntry: state.chatEntry?.copyWith(entries: finalEntries),
          ),
        );

        // Update cache
        if (baseRequest.chatId != null) {
          _updateChatCache(baseRequest.chatId!, serverEntry);
        }
      } else {
        // 7️⃣ Remove failed reply message
        _handleReplyFailure(tempId, updatedEntries);
      }
    } catch (e) {
      log('Error sending reply: $e');
      _handleReplyFailure(tempId, updatedEntries);
    }
  }

  //=============== Handle Reply Failure
  void _handleReplyFailure(int tempId, List<Entry> updatedEntries) {
    final failedEntries = updatedEntries
        .where((entry) => entry.id != tempId)
        .toList();

    emit(
      state.copyWith(
        chatEntry: state.chatEntry?.copyWith(entries: failedEntries),
        errorMessage: 'Failed to send reply',
      ),
    );
  }

  //=============== Start Reply (Instant UI State)
  void startReply(Entry originalMessage) {
    emit(
      state.copyWith(
        isReplying: true,
        replyingTo: originalMessage,
        selectedReplyMessageId: originalMessage.id.toString(),
        selectedReplyMessage: originalMessage,
      ),
    );
  }

  //=============== Cancel Reply (Instant UI State)
  void cancelReply() {
    emit(
      state.copyWith(
        isReplying: false,
        replyingTo: null,
        selectedReplyMessageId: null,
        selectedReplyMessage: null,
      ),
    );
  }

  void pinnedTongle(Entry message, int chatId, int userId) async {
    final messageId = message.id;
    if (messageId == null) {
      emit(state.copyWith(errorMessage: 'Cannot pin message: Invalid ID'));
      return;
    }

    final isPinned = message.pinned?.toLowerCase() == 'y';
    final newPinStatus = isPinned ? 'N' : 'Y';

    final currentEntries = List<Entry>.from(state.chatEntry?.entries ?? []);
    final updatedEntries = currentEntries.map((entry) {
      if (entry.id == messageId) {
        return entry.copyWith(pinned: newPinStatus);
      }
      return entry;
    }).toList();

    await createChat(
      AddChatEntryRequest(
        chatId: chatId,
        senderId: userId,
        type: 'CN',
        typeValue: 0,
        messageType: message.messageType ?? 'text',
        content: message.content ?? '',
        source: 'mobile',
        attachedFiles: [],
        otherDetails1: message.otherDetails1 ?? '',
        pinned: newPinStatus,
      ),
      files: state.selectedFiles,
    );
    emit(
      state.copyWith(
        chatEntry: state.chatEntry?.copyWith(entries: updatedEntries),
        isPinned: newPinStatus,
      ),
    );
  }

  initPinnedClear() {
    emit(state.copyWith(isPinned: null, isMakeItNull: true));
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
      if (fileData['data'] != null && fileData['data'].toString().isNotEmpty) {
        _fileUrls[mediaId] = fileData['data'] ?? '';
        _fileTypes[mediaId] = fileData['type'] ?? 'unknown';
        _fileCacheTimestamps[mediaId] = DateTime.now();
        _failedLoads.remove(mediaId);

        log('Successfully loaded media: $mediaId, type: ${fileData['type']}');
      } else {
        throw Exception('Empty or invalid file data received');
      }

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

  void pinnedToggle(Entry message) {
    // Create a copy of the current entries
    final currentEntries = List<Entry>.from(state.chatEntry?.entries ?? []);

    // Find and update the specific message
    final messageIndex = currentEntries.indexWhere((e) => e.id == message.id);
    if (messageIndex != -1) {
      final currentMessage = currentEntries[messageIndex];
      final newPinnedStatus =
          (currentMessage.pinned ?? '').trim().toUpperCase() == 'Y' ? 'N' : 'Y';

      // Create updated message
      final updatedMessage = Entry(
        id: currentMessage.id,
        chatId: currentMessage.chatId,
        senderId: currentMessage.senderId,
        content: currentMessage.content,
        messageType: currentMessage.messageType,
        createdAt: currentMessage.createdAt,
        // updatedAt: currentMessage.updatedAt,
        sender: currentMessage.sender,
        chatMedias: currentMessage.chatMedias,
        otherDetails1: currentMessage.otherDetails1,
        pinned: newPinnedStatus, // Update pinned status
      );

      // Replace the message in the list
      currentEntries[messageIndex] = updatedMessage;

      // Update the state
      emit(
        state.copyWith(
          chatEntry: state.chatEntry?.copyWith(entries: currentEntries),
        ),
      );
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
        pinned: request.pinned,
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

  // Your existing selectFiles method already supports multiple selection ✅
  Future<void> selectFiles() async {
    if (_isDisposed) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: true, // ✅ Already supports multiple
      );

      if (result != null && !_isDisposed) {
        final files = result.paths.map((path) => File(path!)).toList();
        final currentFiles = state.selectedFiles ?? [];
        final updatedFiles = [...currentFiles, ...files];

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
Future<void> selectMultipleImagesFromGallery() async {
  if (_isDisposed) return;

  try {
    final images = await _imagePicker.pickMultipleMedia(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty && !_isDisposed) {
      final files = images.map((image) => File(image.path)).toList();
      final currentFiles = state.selectedFiles ?? [];
      final updatedFiles = [...currentFiles, ...files];

      emit(state.copyWith(selectedFiles: updatedFiles));
      log('Selected ${files.length} images from gallery');
    }
  } catch (e) {
    if (!_isDisposed) {
      emit(state.copyWith(errorMessage: 'Error selecting images: $e'));
    }
    log('Error selecting multiple images: $e');
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



  // ✅ ALTERNATIVE: Using FilePicker for multiple images
  Future<void> selectMultipleImagesWithFilePicker() async {
    if (_isDisposed) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        // Optional: Compress images
        withData: false, // Don't load data immediately for better performance
      );

      if (result != null && !_isDisposed) {
        final files = result.paths.map((path) => File(path!)).toList();
        final currentFiles = state.selectedFiles ?? [];
        final updatedFiles = [...currentFiles, ...files];

        emit(state.copyWith(selectedFiles: updatedFiles));
        log('Selected ${files.length} images via FilePicker');
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(errorMessage: 'Error selecting images: $e'));
      }
      log('Error selecting images with FilePicker: $e');
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

  Future<void> deleteApi({
    String? chatId,
    String? chatEntryId,
    String? mode,
  }) async {
    final res = await _chatRepositories.deleteChat(
      chatEntryId: chatEntryId,
      chatId: chatId,
      mode: mode,
    );
    if (res.data != null) {
      ChatEntryResponse? updatedChatEntry;
      if (mode == 'CDIS' || mode == 'CDISA') {
        final updatedEntries = state.chatEntry?.entries
            ?.where((e) => e.id != int.parse(chatEntryId ?? ''))
            .toList();

        updatedChatEntry = state.chatEntry?.copyWith(entries: updatedEntries);
      } else {
        updatedChatEntry = state.chatEntry?.copyWith(entries: []);
      }
      emit(state.copyWith(chatEntry: updatedChatEntry));
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
  // bool _isFileLoadedAndValid(String mediaId) {
  //   if (!_fileUrls.containsKey(mediaId)) return false;

  //   final timestamp = _fileCacheTimestamps[mediaId];
  //   if (timestamp == null) return false;

  //   return DateTime.now().difference(timestamp) < _cacheExpiration;
  // }

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

  Future<void> loadCurrentUserId() async {
    try {
      final user = await AuthUtils.instance.readUserData();
      final userId = int.tryParse(user?.result?.userId?.toString() ?? '0') ?? 0;

      emit(state.copyWith(currentUserId: userId, isUserLoaded: true));
    } catch (e) {
      log('Error getting current user ID: $e');
      emit(state.copyWith(currentUserId: 0, isUserLoaded: true));
    }
  }

  //=-=-======================
  // Add these properties to your class
  final bool _isConnecting = false;
  Completer<bool>? _connectionCompleter;
  static const Duration _connectionTimeout = Duration(seconds: 10);

  //=-=-======================
  String _getMimeTypeForFile(String fileType) {
    switch (fileType) {
      case 'image':
        return 'image/jpeg';
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
  //=-=-=-=-= FORWARD MESSAGE

  void startForward(Entry message) {
    emit(
      state.copyWith(
        isForwarding: true,
        forwardingMessage: message,
        isSelectingChatsForForward: true,
        selectedChatsForForward: [],
      ),
    );
    log('🔄 Started forwarding message: ${message.id}');
  }

  // Cancel forwarding
  void cancelForward() {
    emit(
      state.copyWith(
        isForwarding: false,
        clearForwardingMessage: true,
        isSelectingChatsForForward: false,
        selectedChatsForForward: [],
      ),
    );
    log('❌ Cancelled forwarding');
  }

  void toggleChatForForward(ChatListResponse chat) {
    final currentSelected = List<ChatListResponse>.from(
      state.selectedChatsForForward ?? [],
    );

    final isAlreadySelected = currentSelected.any(
      (selected) => selected.chatId == chat.chatId,
    );

    if (isAlreadySelected) {
      currentSelected.removeWhere((selected) => selected.chatId == chat.chatId);
    } else {
      currentSelected.add(chat);
    }

    emit(state.copyWith(selectedChatsForForward: currentSelected));
    log(
      '🔄 Toggled chat ${chat.chatId} for forwarding. Selected: ${currentSelected.length}',
    );
  }

  Future<void> forwardMessageToSelectedChats() async {
    if (state.forwardingMessage == null ||
        state.selectedChatsForForward?.isEmpty != false) {
      emit(
        state.copyWith(
          errorMessage: 'No message or chats selected for forwarding',
        ),
      );
      return;
    }

    try {
      final user = await AuthUtils.instance.readUserData();
      final userId = int.tryParse(user?.result?.userId.toString() ?? '') ?? 0;
      final originalMessage = state.forwardingMessage!;
      final selectedChats = state.selectedChatsForForward!;

      emit(state.copyWith(isForwarding: true));

      for (final chat in selectedChats) {
        List<File> filesToForward = [];

        if (originalMessage.chatMedias?.isNotEmpty == true) {
          log(
            'Processing ${originalMessage.chatMedias!.length} media files for forwarding',
          );

          for (final media in originalMessage.chatMedias!) {
            if (media.mediaUrl != null && media.id != null) {
              try {
                final downloadedFile = await _downloadMediaAsFile(media);
                if (downloadedFile != null) {
                  filesToForward.add(downloadedFile);
                  log('Downloaded file for forwarding: ${downloadedFile.path}');
                }
              } catch (e) {
                log('Failed to download media ${media.id}: $e');
              }
            }
          }
        }

        final forwardRequest = AddChatEntryRequest(
          chatId: chat.chatId,
          senderId: userId,
          type: 'CFVD',
          typeValue: originalMessage.id ?? 0,
          messageType: originalMessage.messageType ?? 'text',
          content: originalMessage.content ?? '',
          attachedFiles: filesToForward,
          source: 'Mobile',
          otherDetails1: jsonEncode([
            {
              "InitialChatEntryId": originalMessage.id.toString(),
              "IsForwarded": "True",
            },
          ]),
        );

        final res = await _chatRepositories.addChatEntry(
          req: forwardRequest,
          files: filesToForward,
        );

        if (res.data == null) {
          throw Exception('Failed to forward to chat ${chat.title}');
        }

        log('Forwarded message to chat: ${chat.title}');

        _cleanupTempFiles(filesToForward);
      }

      emit(
        state.copyWith(
          isForwarding: false,
          clearForwardingMessage: true,
          isSelectingChatsForForward: false,
          selectedChatsForForward: [],
          errorMessage: null,
        ),
      );

      log('Successfully forwarded message to ${selectedChats.length} chats');
    } catch (e) {
      log('Error forwarding message: $e');
      emit(
        state.copyWith(
          isForwarding: false,
          errorMessage: 'Failed to forward message: $e',
        ),
      );
    }
  }

  Future<File?> _downloadMediaAsFile(ChatMedias media) async {
    try {
      if (media.mediaUrl == null || media.id == null) return null;
      final cachedData = _fileUrls[media.id.toString()];
      if (cachedData != null) {
        log('Using cached data for media: ${media.id}');
        return await _createFileFromBase64(cachedData, media);
      }
      log('Downloading media from API: ${media.id}');
      final fileData = await _chatRepositories.getFileFromApi(media.mediaUrl!);

      if (fileData['data'] != null && fileData['data'].toString().isNotEmpty) {
        _fileUrls[media.id.toString()] = fileData['data'];
        _fileTypes[media.id.toString()] = fileData['type'] ?? 'unknown';

        return await _createFileFromBase64(fileData['data'], media);
      }

      return null;
    } catch (e) {
      log('Error downloading media ${media.id}: $e');
      return null;
    }
  }

  Future<File?> _createFileFromBase64(
    String base64Data,
    ChatMedias media,
  ) async {
    try {
      String cleanBase64 = base64Data;
      if (base64Data.contains(',')) {
        cleanBase64 = base64Data.split(',').last;
      }
      final bytes = base64Decode(cleanBase64);
      final tempDir = await getTemporaryDirectory();
      final fileName =
          _extractFileName(media) ??
          'temp_${media.id}_${DateTime.now().millisecondsSinceEpoch}';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);
      log('Created temp file: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      log('Error creating file from base64: $e');
      return null;
    }
  }

  String? _extractFileName(ChatMedias media) {
    try {
      if (media.mediaUrl != null) {
        final uri = Uri.parse(media.mediaUrl!);
        final fileName = path.basename(uri.path);
        if (fileName.isNotEmpty && fileName != '/') {
          return fileName;
        }
      }
      final extension = _getExtensionFromMediaType(media.mediaType);
      return 'media_${media.id}$extension';
    } catch (e) {
      log('Error extracting filename: $e');
      return null;
    }
  }

  String _getExtensionFromMediaType(String? mediaType) {
    if (mediaType == null) return '';

    switch (mediaType.toLowerCase()) {
      case 'image':
        return '.jpg';
      case 'video':
        return '.mp4';
      case 'audio':
        return '.mp3';
      case 'document':
        return '.pdf';
      case 'voice':
        return '.m4a';
      default:
        return '';
    }
  }

  // Cleanup temporary files
  void _cleanupTempFiles(List<File> files) {
    for (final file in files) {
      try {
        if (file.existsSync()) {
          file.deleteSync();
          log('Cleaned up temp file: ${file.path}');
        }
      } catch (e) {
        log('Failed to cleanup temp file: $e');
      }
    }
  }

  Future<void> forwardTextOnlyMessage() async {
    if (state.forwardingMessage == null ||
        state.selectedChatsForForward?.isEmpty != false) {
      emit(
        state.copyWith(
          errorMessage: 'No message or chats selected for forwarding',
        ),
      );
      return;
    }

    try {
      final user = await AuthUtils.instance.readUserData();
      final userId = int.tryParse(user?.result?.userId.toString() ?? '') ?? 0;
      final originalMessage = state.forwardingMessage!;
      final selectedChats = state.selectedChatsForForward!;

      emit(state.copyWith(isForwarding: true));

      for (final chat in selectedChats) {
        final forwardRequest = AddChatEntryRequest(
          chatId: chat.chatId,
          senderId: userId,
          type: 'CFVD',
          typeValue: originalMessage.id ?? 0,
          messageType: 'text',
          content: originalMessage.content ?? '',
          attachedFiles: [],
          source: 'Mobile',
          otherDetails1: jsonEncode([
            {
              "InitialChatEntryId": originalMessage.id.toString(),
              "IsForwarded": "True",
            },
          ]),
        );

        final res = await _chatRepositories.addChatEntry(
          req: forwardRequest,
          files: [],
        );

        if (res.data == null) {
          throw Exception('Failed to forward to chat ${chat.title}');
        }

        log('Forwarded text-only message to chat: ${chat.title}');
      }

      emit(
        state.copyWith(
          isForwarding: false,
          clearForwardingMessage: true,
          isSelectingChatsForForward: false,
          selectedChatsForForward: [],
          errorMessage: null,
        ),
      );

      log(
        'Successfully forwarded text-only message to ${selectedChats.length} chats',
      );
    } catch (e) {
      log('Error forwarding text-only message: $e');
      emit(
        state.copyWith(
          isForwarding: false,
          errorMessage: 'Failed to forward message: $e',
        ),
      );
    }
  }

  // Quick forward to a specific chat (bypassing selection screen)
  Future<void> quickForwardMessage(Entry message, int targetChatId) async {
    try {
      final user = await AuthUtils.instance.readUserData();
      final userId = int.tryParse(user?.result?.userId.toString() ?? '') ?? 0;

      final forwardRequest = AddChatEntryRequest(
        chatId: targetChatId,
        senderId: userId,
        type: 'CFVD',
        typeValue: message.id ?? 0,
        messageType: message.messageType ?? 'text',
        content: message.content ?? '',
        source: 'Mobile',
        attachedFiles: state.selectedFiles,
        otherDetails1: jsonEncode({
          'forwardedFrom': message.chatId,
          'originalMessageId': message.id,
          'originalSender': message.senderId,
          'forwardedAt': DateTime.now().toIso8601String(),
        }),
      );

      final res = await _chatRepositories.addChatEntry(
        req: forwardRequest,
        files: state.selectedFiles,
      );

      if (res.data != null) {
        log('✅ Quick forwarded message to chat: $targetChatId');
      } else {
        throw Exception('Failed to forward message');
      }
    } catch (e) {
      log('❌ Error in quick forward: $e');
      emit(state.copyWith(errorMessage: 'Failed to forward message: $e'));
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

  // Initial state class

  // Helper function for fire-and-forget futures
  void unawaited(Future<void> future) {
    future.catchError((error) {
      log('Unawaited future error: $error');
    });
  }
}
// class ChatPageManager {
//   static bool _isPageVisible = true;
//   static DateTime? _pageHiddenTime;

//   static void onPageVisible() {
//     final wasHidden = !_isPageVisible;
//     _isPageVisible = true;

//     if (wasHidden && _pageHiddenTime != null) {
//       final hiddenDuration = DateTime.now().difference(_pageHiddenTime!);
//       log('📱 Page became visible after ${hiddenDuration.inSeconds}s');

//       // If hidden for more than 30 seconds, refresh chat
//       if (hiddenDuration.inSeconds > 30) {
//         _handlePageComeback();
//       }
//     }
//   }

//   static void onPageHidden() {
//     _isPageVisible = false;
//     _pageHiddenTime = DateTime.now();
//     log('📱 Page became hidden');
//   }

//   static void _handlePageComeback() {
//     log('🔄 Handling page comeback - refreshing chat...');

//     // Get the current chat cubit and refresh
//     // You'll need to access your cubit here
//     // context.read<ChatCubit>().refreshAfterComeback();
//   }
// }
