import 'dart:convert';
import 'dart:developer';

import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_entry/chat_entry_response.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
// 🔧 OPTIMIZED SignalR Service for ReceiveMessage handling

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

    String username = user?.result?.userName?.trim() ?? '';
    username = Uri.encodeComponent(username);

    String baseUrl = "http://20.244.37.96:5002/api/chatsHub";
    if (username.isNotEmpty) {
      baseUrl += "?userName=$username";
    }

    log('🔗 SignalR: Attempting connection to: $baseUrl');

    if (_hubConnection != null && _isConnected) {
      log('SignalR: Already connected');
      return;
    }

    final transportStrategies = [
      HttpTransportType.LongPolling,
      HttpTransportType.ServerSentEvents,
    ];

    Exception? lastError;

    for (final transport in transportStrategies) {
      try {
        log('🔄 SignalR: Trying transport: $transport');
        await _attemptConnection(token ?? '', baseUrl, transport);
        log('✅ SignalR: Successfully connected with $transport');
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        log('❌ SignalR: $transport failed: $e');

        try {
          await _hubConnection?.stop();
        } catch (_) {}
        _hubConnection = null;
        _isConnected = false;
      }
    }

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

    final connectionOptions = HttpConnectionOptions(
      accessTokenFactory: () async {
        log('SignalR: Providing access token...');
        return token;
      },
      transport: transport,
      skipNegotiation: transport == HttpTransportType.WebSockets,
      logMessageContent: true,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(baseUrl, options: connectionOptions)
        .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000, 30000])
        .build();

    _setupEventHandlers();

    try {
      log('SignalR: Starting connection...');
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

      await _testConnection();
    } catch (error) {
      _isConnected = false;
      log('SignalR: ❌ Connection failed with $transport: $error');

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
      onConnected?.call();
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Connection closed. Error: $error');
      onDisconnected?.call();
    });

    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    // ✅ FOCUSED: Since only ReceiveMessage is working, prioritize it
    final primaryMethods = [
      'ReceiveMessage', // 🎯 Primary method that works
      'MessageReceived', // Alternative naming
      'ReceiveChatEntry',
      'ReceiveNewEntries',
      'ReceiveEntryUpdate',
      'ReceiveEntryDeletion',
      'ReceiveTypingStatus',
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
          // ✅ CRITICAL: Handle ReceiveMessage specifically
          _handleReceiveMessage(arguments);
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
          // Fallback to ReceiveMessage handler
          _handleReceiveMessage(arguments);
          break;
      }
    } catch (e) {
      log('❌ SignalR: Error in response handler for $methodName: $e');
      log('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // ✅ OPTIMIZED: Dedicated handler for ReceiveMessage
  void _handleReceiveMessage(dynamic arguments) {
    log('📨 🎯 Processing ReceiveMessage specifically...');

    if (arguments == null || arguments is! List || arguments.isEmpty) {
      log('❌ Invalid ReceiveMessage arguments: $arguments');
      return;
    }

    try {
      final messageData = arguments[0];
      log('📊 ReceiveMessage data type: ${messageData.runtimeType}');
      log(
        '📊 ReceiveMessage data keys: ${messageData is Map ? messageData.keys.toList() : 'Not a map'}',
      );

      Entry? newEntry;

      if (messageData is Map<String, dynamic>) {
        log('✅ Processing Map data as Entry');
        newEntry = _createEntryFromMap(messageData);
      } else if (messageData is String) {
        try {
          log('✅ Processing String data as JSON');
          final parsed = jsonDecode(messageData) as Map<String, dynamic>;
          newEntry = _createEntryFromMap(parsed);
        } catch (e) {
          log('❌ Failed to parse string as JSON: $e');
          return;
        }
      } else {
        log(
          '❌ Unsupported ReceiveMessage data type: ${messageData.runtimeType}',
        );
        return;
      }

      if (newEntry != null) {
        log('✅ 🎯 Successfully created Entry from ReceiveMessage:');
        log('   - ID: ${newEntry.id}');
        log('   - ChatID: ${newEntry.chatId}');
        log('   - Content: "${newEntry.content}"');
        log('   - Sender: ${newEntry.senderId}');
        log('   - Type: ${newEntry.messageType}');
        log('   - Created: ${newEntry.createdAt}');

        // ✅ CRITICAL: Call the handler
        log('🚀 Calling onNewEntriesReceived with new entry...');
        onNewEntriesReceived?.call([newEntry]);
        log('✅ onNewEntriesReceived called successfully');
      } else {
        log('❌ Failed to create Entry from ReceiveMessage data');
      }
    } catch (e) {
      log('❌ Error in _handleReceiveMessage: $e');
      log('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // ✅ ROBUST: Enhanced entry creation from map
  Entry? _createEntryFromMap(Map<String, dynamic> data) {
    try {
      log('🔨 Creating Entry from map with keys: ${data.keys.toList()}');

      // ✅ Handle both camelCase and PascalCase with detailed logging
      final id = data['id'] ?? data['Id'];
      final chatId = data['chatId'] ?? data['ChatId'];
      final senderId = data['senderId'] ?? data['SenderId'];
      final messageType = data['messageType'] ?? data['MessageType'];
      final content = data['content'] ?? data['Content'];
      final createdAt = data['createdAt'] ?? data['CreatedAt'];
      final type = data['type'] ?? data['Type'];
      final typeValue = data['typeValue'] ?? data['TypeValue'];
      final thread = data['thread'] ?? data['Thread'];

      log('🔍 Extracted values:');
      log('   - id: $id (${id.runtimeType})');
      log('   - chatId: $chatId (${chatId.runtimeType})');
      log('   - senderId: $senderId (${senderId.runtimeType})');
      log('   - messageType: $messageType');
      log('   - content: $content');

      final entry = Entry(
        id: id is int ? id : (id is String ? int.tryParse(id) : null),
        chatId: chatId is int
            ? chatId
            : (chatId is String ? int.tryParse(chatId) : null),
        senderId: senderId is int
            ? senderId
            : (senderId is String ? int.tryParse(senderId) : null),
        messageType: messageType?.toString(),
        content: content?.toString(),
        createdAt: createdAt?.toString(),
        type: type?.toString(),
        typeValue: typeValue is int
            ? typeValue
            : (typeValue is String ? int.tryParse(typeValue) : null),
        thread: thread?.toString(),
        chatMedias: _parseChatMedias(data['chatMedias'] ?? data['ChatMedias']),
      );

      log('✅ Entry created successfully');
      return entry;
    } catch (e) {
      log('❌ Error creating Entry from map: $e');
      log('❌ Data: $data');
      return null;
    }
  }

  List<ChatMedias>? _parseChatMedias(dynamic mediasData) {
    if (mediasData == null) return null;

    try {
      if (mediasData is List) {
        return mediasData
            .map((m) => ChatMedias.fromJson(m as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('⚠️ Error parsing chat medias: $e');
    }

    return null;
  }

  // ✅ Keep other handlers for completeness
  void _handleChatEntryResponse(dynamic arguments) {
    log('📨 Processing ChatEntry response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final chatEntryData = arguments[0];
        ChatEntryResponse? chatEntry;

        if (chatEntryData is Map<String, dynamic>) {
          chatEntry = ChatEntryResponse.fromJson(chatEntryData);
        } else if (chatEntryData is String) {
          final jsonData = jsonDecode(chatEntryData) as Map<String, dynamic>;
          chatEntry = ChatEntryResponse.fromJson(jsonData);
        }

        if (chatEntry != null) {
          log(
            '✅ ChatEntry parsed successfully with ${chatEntry.entries?.length ?? 0} entries',
          );
          onChatEntryReceived?.call(chatEntry);
        }
      } catch (e) {
        log('❌ Error parsing chat entry: $e');
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
          onEntryUpdated?.call(entry);
        } else if (entryData is String) {
          final entry = Entry.fromJson(jsonDecode(entryData));
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
          onEntryDeleted?.call(entryId);
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
        onTypingStatusChanged?.call(isTyping, userId);
      } catch (e) {
        log('❌ SignalR: Error parsing typing status: $e');
      }
    }
  }

  Future<void> _testConnection() async {
    if (!_isConnected || _hubConnection == null) return;

    try {
      log('🧪 Testing connection...');
      await _hubConnection!
          .invoke('Ping')
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      log('✅ Connection test successful');
    } catch (e) {
      log('⚠️ Connection test failed: $e');
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
  }

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

  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await initializeConnection();
  }
}
