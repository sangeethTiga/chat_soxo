import 'dart:async';
import 'dart:developer';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

// Enhanced SignalR Service for Chat Data
class ChatSignalRService {
  static final ChatSignalRService _instance = ChatSignalRService._internal();
  factory ChatSignalRService() => _instance;
  ChatSignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _currentChatId;

  // Callbacks for different message types
  Function(dynamic message)? onMessageReceived;
  Function(ChatEntryResponse chatEntry)? onChatEntryReceived;
  Function(List<Entry> newEntries)? onNewEntriesReceived;
  Function(Entry updatedEntry)? onEntryUpdated;
  Function(String entryId)? onEntryDeleted;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(Exception? error)? onError;
  Function(bool isTyping, String userId)? onTypingStatusChanged;

  bool get isConnected => _isConnected;

  Future<void> initializeConnection({
    required String token,
    String baseUrl = "http://20.244.37.96:5002/api/chatsHub",
  }) async {
    final users = await AuthUtils.instance.readUserData();
    if (_hubConnection != null && _isConnected) {
      log('SignalR: Already connected');
      return;
    }
    final customHeaders = MessageHeaders();
    customHeaders.setHeaderValue("userName", users?.result?.userName ?? '');
    try {
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            baseUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
              headers: customHeaders,
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect()
          .build();

      _setupEventHandlers();
      await _hubConnection?.start();
      _isConnected = true;
      log('SignalR: Connected successfully');
      onConnected?.call();
    } catch (error) {
      log('SignalR: Connection failed: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
      rethrow;
    }
  }

  void _setupEventHandlers() {
    _hubConnection?.onreconnecting(({Exception? error}) {
      log('SignalR: Reconnecting. Error: $error');
    });

    _hubConnection?.onreconnected(({String? connectionId}) {
      log('SignalR: Reconnected. ConnectionId: $connectionId');
      if (_currentChatId != null) {
        joinChatGroup(_currentChatId!);
      }
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Connection closed. Error: $error');
      onDisconnected?.call();
    });

    // Listen for different message types
    _hubConnection?.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final message = arguments[0];
        log('SignalR: Received message: $message');
        onMessageReceived?.call(message);
      }
    });

    // Listen for complete chat entry data
    _hubConnection?.on('ReceiveChatEntry', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final chatEntryData = arguments[0] as Map<String, dynamic>;
          final chatEntry = ChatEntryResponse.fromJson(chatEntryData);
          log('SignalR: Received chat entry data');
          onChatEntryReceived?.call(chatEntry);
        } catch (e) {
          log('SignalR: Error parsing chat entry: $e');
        }
      }
    });

    // Listen for new entries
    _hubConnection?.on('ReceiveNewEntries', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final entriesData = arguments[0] as List<dynamic>;
          final entries = entriesData.map((e) => Entry.fromJson(e)).toList();
          log('SignalR: Received new entries: ${entries.length}');
          onNewEntriesReceived?.call(entries);
        } catch (e) {
          log('SignalR: Error parsing new entries: $e');
        }
      }
    });

    // Listen for entry updates
    _hubConnection?.on('ReceiveEntryUpdate', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final entryData = arguments[0] as Map<String, dynamic>;
          final entry = Entry.fromJson(entryData);
          log('SignalR: Received entry update');
          onEntryUpdated?.call(entry);
        } catch (e) {
          log('SignalR: Error parsing entry update: $e');
        }
      }
    });

    // Listen for entry deletions
    _hubConnection?.on('ReceiveEntryDeletion', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final entryId = arguments[0] as String;
        log('SignalR: Received entry deletion: $entryId');
        onEntryDeleted?.call(entryId);
      }
    });

    // Listen for typing status
    _hubConnection?.on('ReceiveTypingStatus', (arguments) {
      if (arguments != null && arguments.length >= 2) {
        final isTyping = arguments[0] as bool;
        final userId = arguments[1] as String;
        onTypingStatusChanged?.call(isTyping, userId);
      }
    });
  }

  // Request chat entry data via SignalR
  Future<void> requestChatEntry(String chatId, String userId) async {
    if (!_isConnected || _hubConnection == null) {
      log('SignalR: Cannot request chat entry - not connected');
      return;
    }

    try {
      await _hubConnection!.invoke('RequestChatEntry', args: [chatId, userId]);
      log('SignalR: Requested chat entry for chat: $chatId');
    } catch (error) {
      log('SignalR: Error requesting chat entry: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
    }
  }

  Future<void> joinChatGroup(String chatId) async {
    if (!_isConnected || _hubConnection == null) {
      log('SignalR: Cannot join group - not connected');
      return;
    }

    try {
      // Leave previous group if exists
      if (_currentChatId != null && _currentChatId != chatId) {
        await _hubConnection!.invoke(
          'LeaveBranchGroup',
          args: [_currentChatId ?? 0],
        );
        log('SignalR: Left previous chat group: $_currentChatId');
      }

      // Join new group
      await _hubConnection!.invoke('JoinBranchGroup', args: [chatId]);
      _currentChatId = chatId;
      log('SignalR: Joined chat group: $chatId');
    } catch (error) {
      log('SignalR: Error joining chat group: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
    }
  }

  // Send a new message via SignalR
  Future<void> sendMessage({
    required String chatId,
    required String userId,
    required String message,
    List<String>? attachments,
  }) async {
    if (!_isConnected || _hubConnection == null) {
      log('SignalR: Cannot send message - not connected');
      return;
    }

    try {
      await _hubConnection!.invoke(
        'SendMessage',
        args: [
          {
            'chatId': chatId,
            'userId': userId,
            'message': message,
            'attachments': attachments ?? [],
            'timestamp': DateTime.now().toIso8601String(),
          },
        ],
      );
      log('SignalR: Message sent');
    } catch (error) {
      log('SignalR: Error sending message: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
    }
  }

  // Send typing status
  Future<void> sendTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke(
        'SendTypingStatus',
        args: [chatId, userId, isTyping],
      );
    } catch (error) {
      log('SignalR: Error sending typing status: $error');
    }
  }

  Future<void> leaveChatGroup(String chatId) async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      await _hubConnection!.invoke('LeaveBranchGroup', args: [chatId]);
      if (_currentChatId == chatId) {
        _currentChatId = null;
      }
      log('SignalR: Left chat group: $chatId');
    } catch (error) {
      log('SignalR: Error leaving chat group: $error');
    }
  }

  Future<void> disconnect() async {
    if (_hubConnection != null) {
      if (_currentChatId != null) {
        await leaveChatGroup(_currentChatId!);
      }
      await _hubConnection!.stop();
      _hubConnection = null;
      _isConnected = false;
      log('SignalR: Disconnected');
    }
  }
}

// // Updated ChatCubit with SignalR-only approach
// @injectable
// class ChatCubit extends Cubit<ChatState> {
//   final ChatRepositories _chatRepositories;
//   final ChatSignalRService _signalRService = ChatSignalRService();

//   // Cache management (for offline support)
//   final Map<int, ChatEntryResponse> _chatCache = {};
//   final Map<int, DateTime> _chatCacheTimestamps = {};
//   static const Duration _chatCacheExpiration = Duration(minutes: 10);

//   int? _currentChatId;
//   bool _isDisposed = false;
//   bool _isSignalRInitialized = false;
//   Timer? _typingTimer;

//   ChatCubit(this._chatRepositories) : super(InitialChatState()) {
//     _initializeSignalR();
//   }

//   Future<void> _initializeSignalR() async {
//     if (_isSignalRInitialized) return;

//     try {
//       final token = await AuthUtils.instance.readAccessToken;
//       final username = await AuthUtils.instance.readUserData();

//       if (token == null || username == null) {
//         log('SignalR: Token or username not found');
//         return;
//       }

//       await _signalRService.initializeConnection(
//         token: token,
//         username: username.result?.userName ?? '',
//       );

//       _setupSignalRCallbacks();
//       _isSignalRInitialized = true;
//     } catch (e) {
//       log('Failed to initialize SignalR: $e');
//       // Fallback to API if SignalR fails
//       emit(state.copyWith(
//         isChatEntry: ApiFetchStatus.failed,
//         errorMessage: 'Failed to establish real-time connection',
//       ));
//     }
//   }

//   void _setupSignalRCallbacks() {
//     // Handle complete chat entry data from SignalR
//     _signalRService.onChatEntryReceived = (chatEntry) {
//       if (_currentChatId != null) {
//         // Cache the data
//         _chatCache[_currentChatId!] = chatEntry;
//         _chatCacheTimestamps[_currentChatId!] = DateTime.now();

//         log('📨 Received chat entry via SignalR for chat $_currentChatId');
//         emit(state.copyWith(
//           chatEntry: chatEntry,
//           isChatEntry: ApiFetchStatus.success,
//           errorMessage: null,
//         ));

//         // Load media in background
//         if (chatEntry.entries?.isNotEmpty == true) {
//           _loadMediaInBackground(chatEntry.entries!);
//         }
//       }
//     };

//     // Handle new entries
//     _signalRService.onNewEntriesReceived = (newEntries) {
//       final currentState = state;
//       if (currentState.chatEntry != null) {
//         final updatedEntries = List<Entry>.from(currentState.chatEntry!.entries ?? []);
//         updatedEntries.addAll(newEntries);

//         final updatedChatEntry = currentState.chatEntry!.copyWith(entries: updatedEntries);
        
//         // Update cache
//         if (_currentChatId != null) {
//           _chatCache[_currentChatId!] = updatedChatEntry;
//           _chatCacheTimestamps[_currentChatId!] = DateTime.now();
//         }

//         emit(state.copyWith(chatEntry: updatedChatEntry));
//         log('📨 Added ${newEntries.length} new entries via SignalR');
//       }
//     };

//     // Handle entry updates
//     _signalRService.onEntryUpdated = (updatedEntry) {
//       final currentState = state;
//       if (currentState.chatEntry?.entries != null) {
//         final entries = currentState.chatEntry!.entries!;
//         final index = entries.indexWhere((e) => e.id == updatedEntry.id);
        
//         if (index != -1) {
//           final updatedEntries = List<Entry>.from(entries);
//           updatedEntries[index] = updatedEntry;
          
//           final updatedChatEntry = currentState.chatEntry!.copyWith(entries: updatedEntries);
          
//           // Update cache
//           if (_currentChatId != null) {
//             _chatCache[_currentChatId!] = updatedChatEntry;
//             _chatCacheTimestamps[_currentChatId!] = DateTime.now();
//           }

//           emit(state.copyWith(chatEntry: updatedChatEntry));
//           log('📨 Updated entry via SignalR: ${updatedEntry.id}');
//         }
//       }
//     };

//     // Handle entry deletions
//     _signalRService.onEntryDeleted = (entryId) {
//       final currentState = state;
//       if (currentState.chatEntry?.entries != null) {
//         final entries = currentState.chatEntry!.entries!;
//         final updatedEntries = entries.where((e) => e.id != entryId).toList();
        
//         final updatedChatEntry = currentState.chatEntry!.copyWith(entries: updatedEntries);
        
//         // Update cache
//         if (_currentChatId != null) {
//           _chatCache[_currentChatId!] = updatedChatEntry;
//           _chatCacheTimestamps[_currentChatId!] = DateTime.now();
//         }

//         emit(state.copyWith(chatEntry: updatedChatEntry));
//         log('📨 Deleted entry via SignalR: $entryId');
//       }
//     };

//     // Handle typing status
//     _signalRService.onTypingStatusChanged = (isTyping, userId) {
//       // Update typing indicators in UI
//       emit(state.copyWith(
//         typingUsers: isTyping 
//           ? [...(state.typingUsers ?? []), userId]
//           : (state.typingUsers ?? []).where((id) => id != userId).toList(),
//       ));
//     };

//     _signalRService.onConnected = () {
//       log('SignalR: Connected successfully');
//       if (_currentChatId != null) {
//         _signalRService.joinChatGroup(_currentChatId.toString());
//       }
//     };

//     _signalRService.onDisconnected = () {
//       log('SignalR: Disconnected');
//       // You could show a "reconnecting" indicator here
//     };

//     _signalRService.onError = (error) {
//       log('SignalR: Error - $error');
//       emit(state.copyWith(
//         isChatEntry: ApiFetchStatus.failed,
//         errorMessage: 'Connection error: ${error.toString()}',
//       ));
//     };
//   }

//   // SignalR-only approach to get chat entry
//   Future<void> getChatEntry({int? chatId, int? userId}) async {
//     final currentChatId = chatId ?? 0;
//     log('📱 Getting chat entry for chatId: $currentChatId (SignalR-only)');

//     // Show loading state
//     emit(state.copyWith(
//       isChatEntry: ApiFetchStatus.loading,
//       chatEntry: null,
//       errorMessage: null,
//     ));

//     if (_isDisposed) return;

//     // Check cache first (for offline support)
//     final cachedData = _chatCache[currentChatId];
//     final cacheTimestamp = _chatCacheTimestamps[currentChatId];
//     final isCacheValid = cachedData != null &&
//         cacheTimestamp != null &&
//         DateTime.now().difference(cacheTimestamp) < _chatCacheExpiration;

//     // If switching chats, join new SignalR group
//     if (_currentChatId != null && _currentChatId != currentChatId) {
//       log('🔄 Switching chats: $_currentChatId -> $currentChatId');
//       if (_signalRService.isConnected) {
//         await _signalRService.joinChatGroup(currentChatId.toString());
//       }
//     }

//     _currentChatId = currentChatId;

//     // Join SignalR group for this chat
//     if (_signalRService.isConnected) {
//       await _signalRService.joinChatGroup(_currentChatId.toString());
      
//       // Request chat entry data via SignalR
//       await _signalRService.requestChatEntry(
//         _currentChatId.toString(),
//         userId.toString(),
//       );
//     } else {
//       // If SignalR is not connected, use cached data or fallback to API
//       if (isCacheValid) {
//         log('💾 Using cached data for chat $currentChatId (SignalR offline)');
//         emit(state.copyWith(
//           chatEntry: cachedData,
//           isChatEntry: ApiFetchStatus.success,
//         ));
//       } else {
//         log('🌐 SignalR offline, falling back to API for chat $currentChatId');
//         await _fallbackToApi(currentChatId, userId ?? 0);
//       }
//     }
//   }



//   // Send message via SignalR instead of API
//   Future<void> sendMessage({
//     required String message,
//     List<String>? attachments,
//   }) async {
//     if (_currentChatId == null) return;

//     final userData = await AuthUtils.instance.readUserData();
//     if (userData?.result?.userId == null) return;

//     if (_signalRService.isConnected) {
//       await _signalRService.sendMessage(
//         chatId: _currentChatId.toString(),
//         userId: userData!.result!.userId.toString(),
//         message: message,
//         attachments: attachments,
//       );
//     } else {
//       // Fallback to API
//       log('SignalR offline, falling back to API for sending message');
//       // Call your existing API method here
//     }
//   }

//   // Send typing status
//   void sendTypingStatus(bool isTyping) {
//     if (_currentChatId == null || !_signalRService.isConnected) return;

//     final userData = AuthUtils.instance.readUserData();
//     userData.then((user) {
//       if (user?.result?.userId != null) {
//         _signalRService.sendTypingStatus(
//           chatId: _currentChatId.toString(),
//           userId: user!.result!.userId.toString(),
//           isTyping: isTyping,
//         );
//       }
//     });

//     // Auto-stop typing after 3 seconds
//     _typingTimer?.cancel();
//     if (isTyping) {
//       _typingTimer = Timer(const Duration(seconds: 3), () {
//         sendTypingStatus(false);
//       });
//     }
//   }

//   void _loadMediaInBackground(List<Entry> entries) {
//     // Your existing media loading logic
//   }


// }