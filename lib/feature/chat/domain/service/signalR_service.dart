import 'dart:convert';
import 'dart:developer';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

class ChatSignalRService {
  static final ChatSignalRService _instance = ChatSignalRService._internal();
  factory ChatSignalRService() => _instance;
  ChatSignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _currentChatId;

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

  void _logResponse(String methodName, dynamic arguments) {
    log('🔍 ===== SignalR Response Debug =====');
    log('📡 Method: $methodName');
    log('📊 Arguments type: ${arguments.runtimeType}');
    log(
      '📊 Arguments length: ${arguments is List ? arguments.length : 'Not a list'}',
    );

    if (arguments != null) {
      try {
        final jsonString = jsonEncode(arguments);
        log('📋 Raw JSON: $jsonString');
        log('📋 Readable format: $arguments');
      } catch (e) {
        log('📋 Non-JSON data: $arguments');
      }
    } else {
      log('📋 Arguments: null');
    }
    log('🔍 ===================================');
  }

  Future<void> initializeConnection() async {
    final user = await AuthUtils.instance.readUserData();
    final token = await AuthUtils.instance.readAccessToken;

    // ✅ FIX 1: Clean up the username parameter
    String username = user?.result?.userName?.trim() ?? '';
    // Remove any special characters that might cause issues
    username = Uri.encodeComponent(username);

    // ✅ FIX 2: Use HTTP (not HTTPS) to match server configuration
    String baseUrl = "http://20.244.37.96:5002/api/chatsHub";
    if (username.isNotEmpty) {
      baseUrl += "?userName=$username";
    }

    log('🔗 SignalR: Attempting connection to: $baseUrl');

    if (_hubConnection != null && _isConnected) {
      log('SignalR: Already connected');
      return;
    }

    // ✅ FIX 3: Try different transport strategies - LongPolling first for HTTP servers
    final transportStrategies = [
      HttpTransportType.LongPolling, // Most reliable for HTTP servers
      HttpTransportType.ServerSentEvents, // Good fallback
      // Skip WebSockets for HTTP servers as they often have TLS issues
    ];

    Exception? lastError;

    for (final transport in transportStrategies) {
      try {
        log('🔄 SignalR: Trying transport: $transport');
        await _attemptConnection(token ?? '', baseUrl, transport);
        log('✅ SignalR: Successfully connected with $transport');
        return; // Success, exit the loop
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        log('❌ SignalR: $transport failed: $e');

        // Clean up failed connection
        try {
          await _hubConnection?.stop();
        } catch (_) {}
        _hubConnection = null;
        _isConnected = false;
      }
    }

    // If all transports failed
    log('❌ SignalR: All transport methods failed');
    onError?.call(lastError ?? Exception('All connection attempts failed'));
    throw lastError ?? Exception('All connection attempts failed');
  }

  Future<void> _attemptConnection(
    String token,
    String baseUrl,
    HttpTransportType transport,
  ) async {
    log('SignalR: Attempting connection with transport: $transport');
    log('SignalR: Using token: ${token.isNotEmpty ? "Present" : "Missing"}');
    log('SignalR: Token length: ${token.length}');

    if (token.isNotEmpty && token.length > 20) {
      log('SignalR: Token starts with: ${token.substring(0, 20)}...');
    }

    // ✅ FIX 4: Improved connection options for HTTP server
    final connectionOptions = HttpConnectionOptions(
      accessTokenFactory: () async {
        log('SignalR: Providing access token...');
        return token;
      },
      transport: transport,
      skipNegotiation: transport == HttpTransportType.WebSockets,
      // ✅ FIX 5: Add timeout and headers for HTTP

      // ✅ FIX 6: Configure logging for better debugging
      logMessageContent: true,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(baseUrl, options: connectionOptions)
        .withAutomaticReconnect(
          retryDelays: [
            2000,
            5000,
            10000,
            20000,
            30000,
          ], // Extended retry delays
        )
        // ✅ FIX 7: Add connection timeout
        .build();

    _setupEventHandlers();

    try {
      log('SignalR: Starting connection...');

      // ✅ FIX 8: Add connection timeout
      await _hubConnection?.start()?.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout after 30 seconds');
        },
      );

      _isConnected = true;
      log('SignalR: ✅ Connected successfully with $transport');
      log('SignalR: Connection ID: ${_hubConnection?.connectionId}');
      onConnected?.call();

      // ✅ FIX 9: Test connection after establishing
      await _testConnection();
    } catch (error) {
      _isConnected = false;
      log('SignalR: ❌ Connection failed with $transport: $error');

      // ✅ FIX 10: Better error analysis
      if (error.toString().contains('401')) {
        log('SignalR: 🔒 Authentication failed - token issue detected');
      } else if (error.toString().contains('400')) {
        log('SignalR: 🔧 Bad Request - check URL format and parameters');
      } else if (error.toString().contains('404')) {
        log('SignalR: 🔍 Hub not found - check endpoint path');
      } else if (error.toString().contains('timeout')) {
        log('SignalR: ⏱️ Connection timeout - server may be slow');
      }

      try {
        await _hubConnection?.stop();
      } catch (_) {}
      _hubConnection = null;
      rethrow;
    }
  }

  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    _hubConnection?.onreconnecting(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Reconnecting. Error: $error');
    });

    _hubConnection?.onreconnected(({String? connectionId}) {
      _isConnected = true;
      log('SignalR: Reconnected. ConnectionId: $connectionId');
      if (_currentChatId != null) {
        joinChatGroup(_currentChatId!);
      }
      onConnected?.call(); // ✅ FIX 11: Notify on reconnection
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Connection closed. Error: $error');
      onDisconnected?.call();
    });

    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    // ✅ Enhanced method list with common SignalR patterns
    final primaryMethods = [
      'ReceiveMessage',
      'ReceiveChatEntry',
      'ReceiveNewEntries',
      'ReceiveEntryUpdate',
      'ReceiveEntryDeletion',
      'ReceiveTypingStatus',
      'MessageReceived', // Alternative naming
      'ChatEntryReceived',
      'NewEntriesReceived',
      'EntryUpdated',
      'EntryDeleted',
      'TypingStatusChanged',
    ];

    for (String methodName in primaryMethods) {
      _hubConnection?.on(methodName, (arguments) {
        log('🎯 SignalR: Method "$methodName" called!');
        _logResponse(methodName, arguments);
        _handleSpecificResponse(methodName, arguments);
      });
    }

    log('✅ SignalR: Set up listeners for ${primaryMethods.length} methods');
  }

  void _handleSpecificResponse(String methodName, dynamic arguments) {
    try {
      log('🔄 Processing $methodName with arguments: $arguments');

      switch (methodName) {
        case 'ReceiveMessage':
        case 'MessageReceived':
          _handleMessageResponse(arguments);
          break;

        case 'ReceiveChatEntry':
        case 'ChatEntryReceived':
          _handleChatEntryResponse(arguments);
          break;

        case 'ReceiveNewEntries':
        case 'NewEntriesReceived':
          _handleNewEntriesResponse(arguments);
          break;

        case 'ReceiveEntryUpdate':
        case 'EntryUpdated':
          _handleEntryUpdateResponse(arguments);
          break;

        case 'ReceiveEntryDeletion':
        case 'EntryDeleted':
          _handleEntryDeletionResponse(arguments);
          break;

        case 'ReceiveTypingStatus':
        case 'TypingStatusChanged':
          _handleTypingStatusResponse(arguments);
          break;

        default:
          log('🤷‍♂️ SignalR: Unknown method "$methodName"');
          if (arguments != null && arguments is List && arguments.isNotEmpty) {
            final data = arguments[0];
            if (data is Map &&
                (data.containsKey('Id') ||
                    data.containsKey('ChatId') ||
                    data.containsKey('id') ||
                    data.containsKey('chatId'))) {
              log('📦 Treating unknown method as chat entry');
              _handleChatEntryResponse(arguments);
            } else {
              log('📦 Treating unknown method as message');
              _handleMessageResponse(arguments);
            }
          }
          break;
      }
    } catch (e) {
      log('❌ SignalR: Error in response handler for $methodName: $e');
    }
  }

  void _handleMessageResponse(dynamic arguments) {
    log('📨 Processing message response...');

    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final messageData = arguments[0];
        log('📊 Message data type: ${messageData.runtimeType}');
        log('📊 Message data: $messageData');

        if (messageData is Map<String, dynamic>) {
          log('🔄 Message contains chat entry structure, converting...');
          _convertMessageToChatEntry(messageData);
          return;
        } else if (messageData is String) {
          try {
            final parsed = jsonDecode(messageData);
            if (parsed is Map<String, dynamic>) {
              _convertMessageToChatEntry(parsed);
              log('🔄 String message contains chat entry JSON, converting...');
              return;
            }
          } catch (e) {
            log('📝 String message is not JSON: $messageData');
          }
        }

        log('✅ Handling as regular message');
        onMessageReceived?.call(messageData);
      } catch (e) {
        log('❌ Error processing message response: $e');
      }
    }
  }

  void _convertMessageToChatEntry(Map<String, dynamic> messageData) {
    try {
      log('🔄 Converting message to chat entry...');

      // ✅ FIX 12: Handle both camelCase and PascalCase properties
      final newEntry = Entry(
        id: messageData['id'] ?? messageData['Id'],
        chatId: messageData['chatId'] ?? messageData['ChatId'],
        senderId: messageData['senderId'] ?? messageData['SenderId'],
        messageType: messageData['messageType'] ?? messageData['MessageType'],
        content: messageData['content'] ?? messageData['Content'],
        createdAt: messageData['createdAt'] ?? messageData['CreatedAt'],
        type: messageData['type'] ?? messageData['Type'],
        typeValue: messageData['typeValue'] ?? messageData['TypeValue'],
        thread: messageData['thread'] ?? messageData['Thread'],
        chatMedias:
            (messageData['chatMedias'] ?? messageData['ChatMedias']) != null
            ? ((messageData['chatMedias'] ?? messageData['ChatMedias']) as List)
                  .map((m) => ChatMedias.fromJson(m))
                  .toList()
            : null,
      );

      log('✅ Created Entry: ID=${newEntry.id}, ChatID=${newEntry.chatId}');
      onNewEntriesReceived?.call([newEntry]);
    } catch (e) {
      log('❌ Error converting message to entry: $e');
    }
  }

  void _handleChatEntryResponse(dynamic arguments) {
    log('📨 Processing ChatEntry response...');

    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final chatEntryData = arguments[0];
        log('📊 ChatEntry data type: ${chatEntryData.runtimeType}');

        ChatEntryResponse? chatEntry;

        if (chatEntryData is Map<String, dynamic>) {
          log('✅ Parsing Map as ChatEntryResponse');
          chatEntry = ChatEntryResponse.fromJson(chatEntryData);
        } else if (chatEntryData is String) {
          log('✅ Parsing JSON string as ChatEntryResponse');
          final jsonData = jsonDecode(chatEntryData) as Map<String, dynamic>;
          chatEntry = ChatEntryResponse.fromJson(jsonData);
        }

        if (chatEntry != null) {
          log(
            '✅ ChatEntry parsed successfully with ${chatEntry.entries?.length ?? 0} entries',
          );
          onChatEntryReceived?.call(chatEntry);
        } else {
          log('❌ Failed to parse ChatEntry');
        }
      } catch (e) {
        log('❌ Error parsing chat entry: $e');
        log('📊 Raw data: $arguments');
      }
    }
  }

  void _handleNewEntriesResponse(dynamic arguments) {
    log('📨 Processing NewEntries response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final entriesData = arguments[0];

        if (entriesData is List) {
          final entries = entriesData.map((e) {
            if (e is Map<String, dynamic>) {
              return Entry.fromJson(e);
            } else if (e is String) {
              return Entry.fromJson(jsonDecode(e));
            } else {
              throw Exception('Invalid entry format: ${e.runtimeType}');
            }
          }).toList();

          log('✅ SignalR: Parsed ${entries.length} new entries');
          onNewEntriesReceived?.call(entries);
        } else {
          log(
            '❌ SignalR: Entries data is not a list: ${entriesData.runtimeType}',
          );
        }
      } catch (e) {
        log('❌ SignalR: Error parsing new entries: $e');
      }
    }
  }

  void _handleEntryUpdateResponse(dynamic arguments) {
    log('📨 Processing EntryUpdate response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final entryData = arguments[0];

        if (entryData is Map<String, dynamic>) {
          final entry = Entry.fromJson(entryData);
          log('✅ SignalR: Entry update parsed');
          onEntryUpdated?.call(entry);
        } else if (entryData is String) {
          final entry = Entry.fromJson(jsonDecode(entryData));
          log('✅ SignalR: Entry update parsed from JSON string');
          onEntryUpdated?.call(entry);
        }
      } catch (e) {
        log('❌ SignalR: Error parsing entry update: $e');
      }
    }
  }

  void _handleEntryDeletionResponse(dynamic arguments) {
    log('📨 Processing EntryDeletion response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final entryId = arguments[0];
        if (entryId is String) {
          log('✅ SignalR: Entry deletion ID: $entryId');
          onEntryDeleted?.call(entryId);
        } else {
          log('❌ SignalR: Entry ID is not a string: ${entryId.runtimeType}');
        }
      } catch (e) {
        log('❌ SignalR: Error parsing entry deletion: $e');
      }
    }
  }

  void _handleTypingStatusResponse(dynamic arguments) {
    log('📨 Processing TypingStatus response...');
    if (arguments != null && arguments is List && arguments.length >= 2) {
      try {
        final isTyping = arguments[0] as bool;
        final userId = arguments[1] as String;
        log('✅ SignalR: Typing status - User: $userId, Typing: $isTyping');
        onTypingStatusChanged?.call(isTyping, userId);
      } catch (e) {
        log('❌ SignalR: Error parsing typing status: $e');
      }
    }
  }

  // ✅ FIX 13: Improved connection testing
  Future<void> _testConnection() async {
    if (!_isConnected || _hubConnection == null) {
      return;
    }

    try {
      log('🧪 Testing connection with basic ping...');
      // Try to invoke a simple method to test the connection
      await _hubConnection!
          .invoke('Ping')
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              log('⚠️ Ping timeout - connection might be unstable');
              return null;
            },
          );
      log('✅ Connection test successful');
    } catch (e) {
      log('⚠️ Connection test failed (this might be normal): $e');
    }
  }

  Future<void> joinChatGroup(String chatId) async {
    if (!_isConnected || _hubConnection == null) {
      log('SignalR: Cannot join group - not connected');
      return;
    }

    try {
      if (_currentChatId != null && _currentChatId != chatId) {
        log('🔄 SignalR: Leaving previous group: $_currentChatId');
        await _hubConnection!.invoke(
          'LeaveBranchGroup',
          args: [_currentChatId!],
        );
        log('✅ SignalR: Left previous chat group: $_currentChatId');
      }

      log('🔄 SignalR: Joining new group: $chatId');
      await _hubConnection!.invoke('JoinBranchGroup', args: [chatId]);
      _currentChatId = chatId;
      log('✅ SignalR: Joined chat group: $chatId');
    } catch (error) {
      log('❌ SignalR: Error joining chat group: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
    }
  }

  void printConnectionInfo() {
    log('🔍 SignalR Connection Info:');
    log('  - Connected: $_isConnected');
    log('  - Current Chat: $_currentChatId');
    log('  - Connection ID: ${_hubConnection?.connectionId ?? "null"}');
    log('  - Connection State: ${_hubConnection?.state ?? "null"}');
    log('  - Hub URL: ${_hubConnection?.baseUrl ?? "null"}');
  }

  // ✅ FIX 15: Add proper disconnect method
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
        log('✅ SignalR: Disconnected successfully');
      } catch (e) {
        log('⚠️ SignalR: Error during disconnect: $e');
      }
    }
    _isConnected = false;
    _currentChatId = null;
    _hubConnection = null;
  }

  // ✅ FIX 16: Add connection retry method
  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await initializeConnection();
  }
}
