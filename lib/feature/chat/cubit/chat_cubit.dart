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

      // ✅ CRITICAL: Create completely new ChatEntryResponse instance
      final updatedChatEntry = ChatEntryResponse(
        entries: updatedEntries,
        userChats: state.chatEntry!.userChats,
      );

      // Update cache
      _chatCache[_currentChatId!] = updatedChatEntry;
      _chatCacheTimestamps[_currentChatId!] = DateTime.now();

      log(
        '🚀 🎯 EMITTING STATE UPDATE with ${filteredNewEntries.length} new entries',
      );
      log('📊 Previous state hash: ${state.hashCode}');
      log('📊 Previous entries hash: ${state.chatEntry?.entries?.hashCode}');

      // ✅ CRITICAL: Force complete state recreation
      final newState = ChatState(
        // Copy all existing properties
        isArrow: state.isArrow,
        isRecording: state.isRecording,
        recordingDuration: state.recordingDuration,
        recordingPath: state.recordingPath,
        hasRecordingPermission: state.hasRecordingPermission,
        chatList: state.chatList,
        isChat: state.isChat,
        selectedTab: state.selectedTab,
        allChats: state.allChats,
        selectedFiles: state.selectedFiles,
        isUploadingFiles: state.isUploadingFiles,
        uploadProgress: state.uploadProgress,
        fileUrls: Map<String, String>.from(state.fileUrls ?? {}),
        fileTypes: Map<String, String>.from(state.fileTypes ?? {}),
        viewingFile: state.viewingFile,
        isLoadingMedia: state.isLoadingMedia,
        // ✅ Update critical properties with new instances
        chatEntry: updatedChatEntry,
        isChatEntry: ApiFetchStatus.success,
        errorMessage: null,
      );

      log('📊 New state hash: ${newState.hashCode}');
      log('📊 New entries hash: ${newState.chatEntry?.entries?.hashCode}');

      // ✅ EMIT the new state
      emit(newState);

      // ✅ Load media for new entries
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

  // ✅ ENHANCED: Override emit method with better debugging
  @override
  void emit(ChatState state) {
    if (_isDisposed) {
      log('⚠️ Attempted to emit on disposed cubit');
      return;
    }

    final previousEntriesCount = this.state.chatEntry?.entries?.length ?? 0;
    final newEntriesCount = state.chatEntry?.entries?.length ?? 0;
    final previousHash = this.state.hashCode;
    final newHash = state.hashCode;

    log('🚀 🎯 EMITTING STATE FROM RECEIVEMESSAGE:');
    log('  - Status: ${this.state.isChatEntry} → ${state.isChatEntry}');
    log('  - Entries: $previousEntriesCount → $newEntriesCount');
    log('  - State hash: $previousHash → $newHash');
    log(
      '  - Entries hash: ${this.state.chatEntry?.entries?.hashCode} → ${state.chatEntry?.entries?.hashCode}',
    );
    log('  - Hash changed: ${previousHash != newHash}');

    super.emit(state);

    // ✅ Verify emit was successful
    Future.delayed(Duration(milliseconds: 50), () {
      if (!_isDisposed) {
        final actualCount = this.state.chatEntry?.entries?.length ?? 0;
        final actualHash = this.state.hashCode;

        log('✅ 🎯 Emit verification:');
        log('  - Expected entries: $newEntriesCount, Actual: $actualCount');
        log('  - Expected hash: $newHash, Actual: $actualHash');

        if (actualCount != newEntriesCount) {
          log('❌ EMIT FAILED: Entry counts don\'t match!');
        } else if (actualHash != newHash) {
          log('❌ EMIT FAILED: State hashes don\'t match!');
        } else {
          log('✅ EMIT SUCCESS: State updated correctly');
        }
      }
    });
  }

  // ✅ BONUS: Add a method to manually test ReceiveMessage
  void testReceiveMessage() {
    log('🧪 Testing ReceiveMessage simulation...');

    final testEntry = Entry(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: _currentChatId,
      senderId: 999,
      messageType: 'text',
      content: 'Test ReceiveMessage: ${DateTime.now().toIso8601String()}',
      createdAt: DateTime.now().toIso8601String(),
      type: 'N',
      typeValue: 0,
      thread: '47',
    );

    log('🧪 Simulating ReceiveMessage with test entry...');
    _handleNewEntries([testEntry]);
  }
  // void _handleNewEntries(List<Entry> newEntries) {
  //   log('📨 SignalR: Received ${newEntries.length} new entries');
  //   log('📊 Current chat ID: $_currentChatId');
  //   log('📊 Current chat state: ${state.isChatEntry}');
  //   log('📊 Has chatEntry: ${state.chatEntry != null}');

  //   if (_isDisposed) {
  //     log('⚠️ Cubit is disposed, ignoring new entries');
  //     return;
  //   }

  //   if (_currentChatId == null) {
  //     log('⚠️ No current chat ID set');
  //     return;
  //   }

  //   if (state.chatEntry == null) {
  //     log('⚠️ No chat entry state - requesting fresh data');
  //     getChatEntry(chatId: _currentChatId);
  //     return;
  //   }

  //   final currentChatIdStr = _currentChatId.toString();
  //   final relevantEntries = newEntries.where((entry) {
  //     final entryChatId = entry.chatId?.toString() ?? '';
  //     final isRelevant = entryChatId == currentChatIdStr;
  //     log(
  //       '🔍 Entry ${entry.id}: chatId="$entryChatId" vs current="$currentChatIdStr" -> $isRelevant',
  //     );
  //     return isRelevant;
  //   }).toList();

  //   log('📊 Relevant entries for current chat: ${relevantEntries.length}');

  //   if (relevantEntries.isEmpty) {
  //     log('ℹ️ No relevant entries for current chat $_currentChatId');
  //     return;
  //   }

  //   // ✅ FIX 1: Create completely new list instances to ensure state change detection
  //   final currentEntries = List<Entry>.from(state.chatEntry!.entries ?? []);
  //   final existingIds = currentEntries
  //       .map((e) => e.id?.toString())
  //       .where((id) => id != null)
  //       .toSet();

  //   final filteredNewEntries = relevantEntries.where((entry) {
  //     final entryId = entry.id?.toString();
  //     final isNew = entryId != null && !existingIds.contains(entryId);
  //     log('🔍 Entry ${entry.id}: exists=${!isNew}');
  //     return isNew;
  //   }).toList();

  //   log(
  //     '📊 New entries after filtering duplicates: ${filteredNewEntries.length}',
  //   );

  //   if (filteredNewEntries.isEmpty) {
  //     log('ℹ️ No new entries to add (all already exist)');
  //     return;
  //   }

  //   try {
  //     // ✅ FIX 2: Create completely new list for Freezed
  //     final updatedEntries = List<Entry>.from([
  //       ...currentEntries,
  //       ...filteredNewEntries,
  //     ]);

  //     // ✅ FIX 3: Use Freezed copyWith properly
  //     final updatedChatEntry = state.chatEntry!.copyWith(
  //       entries: updatedEntries, // Freezed will create new object automatically
  //     );

  //     // Update cache
  //     _chatCache[_currentChatId!] = updatedChatEntry;
  //     _chatCacheTimestamps[_currentChatId!] = DateTime.now();

  //     log(
  //       '🚀 EMITTING STATE UPDATE with ${filteredNewEntries.length} new entries',
  //     );
  //     log('📊 Total entries now: ${updatedEntries.length}');

  //     // ✅ FIX 4: Use regular emit with copyWith for Freezed compatibility
  //     emit(
  //       state.copyWith(
  //         chatEntry: updatedChatEntry,
  //         isChatEntry: ApiFetchStatus.success,
  //         errorMessage: null, // Clear any errors
  //       ),
  //     );

  //     // ✅ FIX 6: Load media immediately for new entries
  //     _loadMediaForNewEntries(filteredNewEntries);

  //     log('✅ STATE EMITTED SUCCESSFULLY');

  //     // ✅ FIX 7: Remove the double emit for Freezed
  //     // Freezed handles immutability properly, no need for double emission

  //     // Debug verification
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       log('🔍 Post-emit verification:');
  //       log('  - State entries: ${state.chatEntry?.entries?.length}');
  //       log('  - State status: ${state.isChatEntry}');
  //       log('  - State hash: ${state.hashCode}');
  //     });
  //   } catch (e) {
  //     log('❌ Error updating state with new entries: $e');
  //     emit(state.copyWith(errorMessage: 'Failed to update chat: $e'));
  //   }
  // }

  // ✅ FIX 8: Override emit method to force logging and detection

  // void _handleNewEntries(List<Entry> newEntries) {
  //   log('📨 SignalR: Received ${newEntries.length} new entries');
  //   log('📊 Current chat ID: $_currentChatId');
  //   log('📊 Current chat state: ${state.isChatEntry}');
  //   log('📊 Has chatEntry: ${state.chatEntry != null}');

  //   if (_isDisposed) {
  //     log('⚠️ Cubit is disposed, ignoring new entries');
  //     return;
  //   }

  //   if (_currentChatId == null) {
  //     log('⚠️ No current chat ID set');
  //     return;
  //   }

  //   if (state.chatEntry == null) {
  //     log('⚠️ No chat entry state - requesting fresh data');
  //     getChatEntry(chatId: _currentChatId);
  //     return;
  //   }

  //   // ✅ Check for media entries first
  //   final entriesWithMedia = newEntries
  //       .where((entry) => entry.chatMedias?.isNotEmpty == true)
  //       .toList();

  //   if (entriesWithMedia.isNotEmpty) {
  //     log('📎 Found ${entriesWithMedia.length} entries with media files');
  //     for (var entry in entriesWithMedia) {
  //       log('📎 Entry ${entry.id} has ${entry.chatMedias?.length} media files');
  //       for (var media in entry.chatMedias ?? []) {
  //         log(
  //           '📎 Media: ID=${media.id}, URL=${media.mediaUrl}, Type=${media.mediaType}',
  //         );
  //       }
  //     }
  //   }

  //   final currentChatIdStr = _currentChatId.toString();
  //   final relevantEntries = newEntries.where((entry) {
  //     final entryChatId = entry.chatId?.toString() ?? '';
  //     final isRelevant = entryChatId == currentChatIdStr;
  //     log(
  //       '🔍 Entry ${entry.id}: chatId="$entryChatId" vs current="$currentChatIdStr" -> $isRelevant',
  //     );
  //     return isRelevant;
  //   }).toList();

  //   log('📊 Relevant entries for current chat: ${relevantEntries.length}');

  //   if (relevantEntries.isEmpty) {
  //     log('ℹ️ No relevant entries for current chat $_currentChatId');
  //     return;
  //   }

  //   final currentEntries = List<Entry>.from(state.chatEntry!.entries ?? []);
  //   final existingIds = currentEntries
  //       .map((e) => e.id?.toString())
  //       .where((id) => id != null)
  //       .toSet();

  //   final filteredNewEntries = relevantEntries.where((entry) {
  //     final entryId = entry.id?.toString();
  //     final isNew = entryId != null && !existingIds.contains(entryId);
  //     log('🔍 Entry ${entry.id}: exists=${!isNew}');
  //     return isNew;
  //   }).toList();

  //   log(
  //     '📊 New entries after filtering duplicates: ${filteredNewEntries.length}',
  //   );

  //   if (filteredNewEntries.isEmpty) {
  //     log('ℹ️ No new entries to add (all already exist)');
  //     return;
  //   }

  //   try {
  //     final updatedEntries = [...currentEntries, ...filteredNewEntries];
  //     final updatedChatEntry = state.chatEntry!.copyWith(
  //       entries: updatedEntries,
  //     );

  //     // Update cache
  //     _chatCache[_currentChatId!] = updatedChatEntry;
  //     _chatCacheTimestamps[_currentChatId!] = DateTime.now();

  //     log(
  //       '🚀 EMITTING STATE UPDATE with ${filteredNewEntries.length} new entries',
  //     );
  //     log('📊 Total entries now: ${updatedEntries.length}');

  //     // ✅ CRITICAL: Emit the new state
  //     emit(
  //       state.copyWith(
  //         chatEntry: updatedChatEntry,
  //         isChatEntry: ApiFetchStatus.success,
  //         errorMessage: null,
  //       ),
  //     );

  //     // ✅ IMMEDIATELY load media for new entries (this was missing!)
  //     _loadMediaForNewEntries(filteredNewEntries);

  //     log('✅ STATE EMITTED SUCCESSFULLY');

  //     // Debug verification
  //     Future.delayed(Duration(milliseconds: 100), () {
  //       log('🔍 Post-emit verification:');
  //       log('  - State entries: ${state.chatEntry?.entries?.length}');
  //       log('  - State status: ${state.isChatEntry}');
  //     });
  //   } catch (e) {
  //     log('❌ Error updating state with new entries: $e');
  //     emit(state.copyWith(errorMessage: 'Failed to update chat: $e'));
  //   }
  // }

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

  // Enhanced getChatEntry method with proper SignalR handling
  Future<void> getChatEntry({int? chatId}) async {
    final currentChatId = chatId ?? 0;
    log('📱 🔄 Getting chat entry for chatId: $currentChatId');

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

    if (_isDisposed) return;

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

      // Establish proper SignalR connection BEFORE loading data
      final signalRConnected = await _establishSignalRConnection(currentChatId);
      if (!signalRConnected) {
        log('⚠️ SignalR connection failed, but continuing with API call...');
      }

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

      // Final sync with SignalR
      await _finalizeSignalRConnection(currentChatId);
    } catch (e) {
      log('❌ Error in getChatEntry for chat $currentChatId: $e');
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

    emit(
      state.copyWith(
        chatEntry: cachedData,
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

      emit(
        state.copyWith(
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
      await _signalRService.sendPing();

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

  // Enhanced refresh method for comeback scenarios
  Future<void> refreshAfterComeback() async {
    log('🔄 Refreshing chat after comeback...');

    if (_currentChatId == null) {
      log('⚠️ No current chat ID for refresh');
      return;
    }

    try {
      // Clear all cached data
      _chatCache.clear();
      _chatCacheTimestamps.clear();

      // Reset state
      _isFirstLoad = true;
      _hasPendingUpdates = false;
      _batchUpdateTimer?.cancel();

      // Force disconnect and reconnect SignalR
      await _forceSignalRReconnection();

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

  // Force SignalR reconnection
  Future<void> _forceSignalRReconnection() async {
    try {
      log('🔄 Forcing SignalR reconnection...');

      // Disconnect completely
      if (_signalRService.isConnected) {
        await _signalRService.disconnect();
        await Future.delayed(Duration(milliseconds: 1000));
      }

      // Reconnect with retry logic
      final connected = await _connectSignalRWithRetry();

      if (connected) {
        log('✅ SignalR force reconnection successful');
      } else {
        log('❌ SignalR force reconnection failed');
      }
    } catch (e) {
      log('❌ Error during SignalR force reconnection: $e');
    }
  }

  // Add these properties to your ChatCubit class
  int? _previousSignalRChatId;
  bool _isFirstLoad = true;

  // Enhanced connection monitoring
  void _startConnectionMonitoring() {
    Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }

      if (!_signalRService.isConnected && _currentChatId != null) {
        log('⚠️ SignalR connection lost, attempting reconnection...');
        _establishSignalRConnection(_currentChatId!);
      }
    });
  }
  // Future<void> getChatEntry({int? chatId}) async {
  //   final currentChatId = chatId ?? 0;
  //   log('📱 Getting chat entry for chatId: $currentChatId');

  //   final previousChatId = _currentChatId;
  //   _currentChatId = currentChatId;
  //   emit(
  //     state.copyWith(
  //       isChatEntry: ApiFetchStatus.loading,
  //       chatEntry: null,
  //       errorMessage: null,
  //     ),
  //   );

  //   if (_isDisposed) return;

  //   if (previousChatId != null && previousChatId != currentChatId) {
  //     log('🔄 Switching chats: $previousChatId -> $currentChatId');
  //   }

  //   if (_signalRService.isConnected) {
  //     await _signalRService.joinChatGroup(currentChatId.toString());
  //     log('🔗 Joining SignalR group for chat $currentChatId');

  //     log('📡 Requested SignalR updates for chat $currentChatId');
  //   } else {
  //     log('⚠️ SignalR not connected, cannot join group');
  //   }

  //   final cachedData = _chatCache[currentChatId];
  //   final cacheTimestamp = _chatCacheTimestamps[currentChatId];
  //   final isCacheValid =
  //       cachedData != null &&
  //       cacheTimestamp != null &&
  //       DateTime.now().difference(cacheTimestamp) < _chatCacheExpiration;

  //   if (isCacheValid) {
  //     log('💾 Using cached data for chat $currentChatId');
  //     await Future.delayed(const Duration(milliseconds: 400));

  //     if (_isDisposed) return;

  //     emit(
  //       state.copyWith(
  //         chatEntry: cachedData,
  //         isChatEntry: ApiFetchStatus.success,
  //       ),
  //     );

  //     if (cachedData.entries?.isNotEmpty == true) {
  //       _loadMediaInBackground(cachedData.entries!);
  //     }
  //     return;
  //   }

  //   try {
  //     log('🌐 Making API call for chat $currentChatId');
  //     final res = await _chatRepositories.chatEntry(currentChatId);

  //     if (_isDisposed) return;

  //     if (res.data != null) {
  //       _chatCache[currentChatId] = res.data!;
  //       _chatCacheTimestamps[currentChatId] = DateTime.now();

  //       log('✅ Successfully loaded chat entry for chat $currentChatId');
  //       log('📊 Loaded ${res.data!.entries?.length ?? 0} entries');

  //       emit(
  //         state.copyWith(
  //           chatEntry: res.data,
  //           isChatEntry: ApiFetchStatus.success,
  //         ),
  //       );

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
  //     log('❌ Error getting chat entry for chat $currentChatId: $e');
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
          "InitialChatEntryId": originalMessage.id.toString(),
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
            "InitialChatEntryId": originalMessage.id.toString(),
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
    emit(state.copyWith(isReplying: true, replyingTo: originalMessage));
  }

  //=============== Cancel Reply (Instant UI State)
  void cancelReply() {
    emit(state.copyWith(isReplying: false, replyingTo: null));
  }

  void pinnedTongle(Entry message) {
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
    emit(
      state.copyWith(
        chatEntry: state.chatEntry?.copyWith(entries: updatedEntries),
        isPinned: newPinStatus,
      ),
    );
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

      final optimisticEntry = Entry(
        id: tempId,
        chatId: request.chatId,
        senderId: request.senderId,
        messageType: request.messageType,
        content: request.content,
        createdAt: DateTime.now().toIso8601String(),
        otherDetails1: request.otherDetails1 ?? '',
        pinned: request.pinned,
      );
      final res = await _chatRepositories.addChatEntry(
        req: request,
        files: filesToSend,
      );

      if (_isDisposed) return;

      if (res.data != null) {
        addOptimisticMessage(optimisticEntry);

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

  void addOptimisticMessage(Entry optimisticEntry) {
    final currentEntries = List<Entry>.from(state.chatEntry?.entries ?? []);
    currentEntries.add(optimisticEntry);

    emit(
      state.copyWith(
        chatEntry: state.chatEntry?.copyWith(entries: currentEntries),
      ),
    );
  }

  void updateOptimisticMessage({
    required String tempId,
    Entry? realEntry,
    bool remove = false,
  }) {
    final currentEntries = List<Entry>.from(state.chatEntry?.entries ?? []);
    final index = currentEntries.indexWhere((e) => e.id.toString() == tempId);

    if (index != -1) {
      if (remove) {
        currentEntries.removeAt(index);
      } else if (realEntry != null) {
        currentEntries[index] = realEntry;
      }

      emit(
        state.copyWith(
          chatEntry: state.chatEntry?.copyWith(entries: currentEntries),
        ),
      );
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

class ChatPageManager {
  static bool _isPageVisible = true;
  static DateTime? _pageHiddenTime;

  static void onPageVisible() {
    final wasHidden = !_isPageVisible;
    _isPageVisible = true;

    if (wasHidden && _pageHiddenTime != null) {
      final hiddenDuration = DateTime.now().difference(_pageHiddenTime!);
      log('📱 Page became visible after ${hiddenDuration.inSeconds}s');

      // If hidden for more than 30 seconds, refresh chat
      if (hiddenDuration.inSeconds > 30) {
        _handlePageComeback();
      }
    }
  }

  static void onPageHidden() {
    _isPageVisible = false;
    _pageHiddenTime = DateTime.now();
    log('📱 Page became hidden');
  }

  static void _handlePageComeback() {
    log('🔄 Handling page comeback - refreshing chat...');

    // Get the current chat cubit and refresh
    // You'll need to access your cubit here
    // context.read<ChatCubit>().refreshAfterComeback();
  }
}
