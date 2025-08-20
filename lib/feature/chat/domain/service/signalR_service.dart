import 'dart:async';
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

  DateTime? _lastActivity;
  Timer? _activityTimer;
  HubConnection? _hubConnection;
  bool _isConnected = false;
  String? _currentChatId;
  bool _isConnecting = false;
  Completer<void>? _connectionCompleter;
  Timer? _connectionTimeoutTimer;
  int _connectionAttempts = 0;

  // Configuration constants
  static const Duration _maxConnectionWait = Duration(seconds: 15);
  static const int _maxConcurrentAttempts = 3;

  // Callback functions
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
    log('🔗 SignalR: initializeConnection called');

    // Check if already connected
    if (_hubConnection != null && _isConnected) {
      log('✅ SignalR: Already connected');
      return;
    }

    // Handle concurrent attempts with timeout
    if (_isConnecting) {
      log('⏳ Connection in progress, waiting with timeout...');

      if (_connectionCompleter != null) {
        try {
          await _connectionCompleter!.future.timeout(
            _maxConnectionWait,
            onTimeout: () {
              log('⏰ Connection wait timed out, forcing reset');
              _forceResetConnectionState();
              throw TimeoutException(
                'Connection wait timeout',
                _maxConnectionWait,
              );
            },
          );
          return;
        } catch (e) {
          log('❌ Error waiting for connection: $e');
          _forceResetConnectionState();
        }
      }
    }

    // Increment attempt counter and check limit
    _connectionAttempts++;
    if (_connectionAttempts > _maxConcurrentAttempts) {
      log('❌ Too many connection attempts ($_connectionAttempts), resetting');
      await _forceResetConnectionState();
      _connectionAttempts = 0;
    }

    // Start connection attempt
    _isConnecting = true;
    _connectionCompleter = Completer<void>();

    // Set up timeout timer
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(_maxConnectionWait, () {
      if (_isConnecting) {
        log('⏰ Connection attempt timed out');
        _handleConnectionTimeout();
      }
    });

    try {
      log('🚀 Starting new connection attempt #$_connectionAttempts');
      await _performConnection();

      _connectionAttempts = 0; // Reset on success
      log('✅ Connection successful, reset attempt counter');
    } catch (e) {
      log('❌ Connection attempt #$_connectionAttempts failed: $e');
      _handleConnectionFailure(e);
      rethrow;
    } finally {
      _connectionTimeoutTimer?.cancel();
    }
  }

  void _handleConnectionTimeout() {
    log('⏰ Connection timeout reached');
    _handleConnectionFailure(
      TimeoutException('Connection timeout', _maxConnectionWait),
    );
  }

  Future<void> _performConnection() async {
    final user = await AuthUtils.instance.readUserData();
    String username = user?.result?.userName?.trim() ?? '';
    final String token = user?.result?.jwtToken ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    username = Uri.encodeComponent(username);

    List<String> baseUrls = [
      "http://20.244.37.96:5002/api/chatsHub",
      "https://20.244.37.96:5002/api/chatsHub",
    ];

    if (username.isNotEmpty) {
      baseUrls = baseUrls.map((url) => "$url?userName=$username").toList();
    }

    Exception? lastError;

    for (final baseUrl in baseUrls) {
      final transportStrategies = [
        HttpTransportType.LongPolling,
        HttpTransportType.WebSockets,
        HttpTransportType.ServerSentEvents,
      ];

      for (final transport in transportStrategies) {
        try {
          log('🔄 Trying $baseUrl with transport: $transport');
          await _attemptConnection(token, baseUrl, transport);

          // Success - complete the completer and update state
          _isConnected = true;
          _isConnecting = false;

          if (_connectionCompleter != null &&
              !_connectionCompleter!.isCompleted) {
            _connectionCompleter!.complete();
          }

          onConnected?.call();
          _startActivityTracking();

          log('✅ Successfully connected with $transport to $baseUrl');
          return;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          log('❌ $transport on $baseUrl failed: $e');

          await _cleanupFailedConnection();

          // Skip HTTPS if SSL/TLS errors
          if (baseUrl.startsWith('https://') && _isSSLError(e)) {
            log(
              '⚠️ SSL/TLS error detected, skipping remaining transports for HTTPS',
            );
            break;
          }
        }
      }
    }

    throw lastError ?? Exception('All connection attempts failed');
  }

  bool _isSSLError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('handshakeexception') ||
        errorString.contains('wrong_version_number') ||
        errorString.contains('tls') ||
        errorString.contains('ssl');
  }

  void _handleConnectionFailure(dynamic error) {
    log('❌ Handling connection failure: $error');

    _connectionTimeoutTimer?.cancel();

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter!.completeError(error);
    }

    _isConnecting = false;
    _connectionCompleter = null;
    _isConnected = false;

    unawaited(_cleanupFailedConnection());
    onError?.call(error is Exception ? error : Exception(error.toString()));
  }

  Future<void> _forceResetConnectionState() async {
    log('🔄 Force resetting connection state');

    _connectionTimeoutTimer?.cancel();

    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      _connectionCompleter!.completeError(Exception('Connection force reset'));
    }

    _isConnecting = false;
    _connectionCompleter = null;

    if (_hubConnection != null && !_isConnected) {
      try {
        await _hubConnection!.stop();
      } catch (e) {
        log('⚠️ Error stopping connection during reset: $e');
      }
      _hubConnection = null;
    }

    _isConnected = false;
    log('✅ Connection state force reset complete');
  }

  Future<void> _cleanupFailedConnection() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop().timeout(
          Duration(seconds: 5),
          onTimeout: () {
            log('⚠️ Connection stop timeout during cleanup');
          },
        );
      }
    } catch (e) {
      log('⚠️ Error during cleanup: $e');
    } finally {
      _hubConnection = null;
      _isConnected = false;
    }
  }

  void _startActivityTracking() {
    _activityTimer?.cancel();
    _activityTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _lastActivity = DateTime.now();
        log('📊 SignalR activity tracked: $_lastActivity');
      }
    });
  }

  bool get isComingBackFromInactivity {
    if (_lastActivity == null) return false;
    final inactiveTime = DateTime.now().difference(_lastActivity!);
    return inactiveTime.inMinutes > 2;
  }

  Future<void> _attemptConnection(
    String token,
    String baseUrl,
    HttpTransportType transport,
  ) async {
    log('SignalR: Attempting connection with transport: $transport');
    log(
      'SignalR: Using token: ${token.isNotEmpty ? "Present (${token.length} chars)" : "Missing"}',
    );
    log('SignalR: Target URL: $baseUrl');

    final isHttps = baseUrl.startsWith('https://');
    log('SignalR: Using ${isHttps ? "HTTPS" : "HTTP"} connection');

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
        .withAutomaticReconnect(
          retryDelays: [1000, 2000, 5000, 10000, 15000, 30000],
        )
        .build();

    _setupEventHandlers();

    try {
      log('SignalR: Starting connection...');

      await _hubConnection?.start()?.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException(
            'Connection timeout after 60 seconds',
            Duration(seconds: 60),
          );
        },
      );

      if (_hubConnection?.connectionId == null) {
        throw Exception('Connection established but no connection ID received');
      }

      _isConnected = true;
      log('SignalR: ✅ Connected successfully with $transport');
      log('SignalR: Connection ID: ${_hubConnection?.connectionId}');
      onConnected?.call();
    } catch (error) {
      _isConnected = false;
      log('SignalR: ❌ Connection failed with $transport: $error');
      await _cleanupFailedConnection();
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
        Future.delayed(Duration(milliseconds: 500), () {
          joinChatGroup(_currentChatId!);
        });
      }
      onConnected?.call();
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Connection closed. Error: $error');
      onDisconnected?.call();

      if (error != null) {
        log('🔄 Attempting auto-reconnect due to unexpected closure...');
        Future.delayed(Duration(seconds: 2), () {
          if (!_isConnected && !_isConnecting) {
            initializeConnection().catchError((e) {
              log('❌ Auto-reconnect failed: $e');
            });
          }
        });
      }
    });

    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    final primaryMethods = [
      'ReceiveMessage',
      'MessageReceived',
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

        try {
          _handleSpecificResponse(methodName, arguments);
        } catch (e) {
          log('❌ Error in message handler for $methodName: $e');
        }
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
          _handleReceiveMessage(arguments);
          break;
      }
    } catch (e) {
      log('❌ SignalR: Error in response handler for $methodName: $e');
      log('❌ Stack trace: ${StackTrace.current}');
    }
  }

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

  Entry? _createEntryFromMap(Map<String, dynamic> data) {
    try {
      log('🔨 Creating Entry from map with keys: ${data.keys.toList()}');

      final id = data['id'] ?? data['Id'];
      final chatId = data['chatId'] ?? data['ChatId'];
      final senderId = data['senderId'] ?? data['SenderId'];
      final messageType = data['messageType'] ?? data['MessageType'];
      final content = data['content'] ?? data['Content'];
      final createdAt = data['createdAt'] ?? data['CreatedAt'];
      final type = data['type'] ?? data['Type'];
      final typeValue = data['typeValue'] ?? data['TypeValue'];
      final thread = data['thread'] ?? data['Thread'];
      final otherDetails1 = data['otherDetails1'];
      final pinned = data['pinned'];

      log('🔍 Extracted values:');
      log('   - id: $id (${id.runtimeType})');
      log('   - chatId: $chatId (${chatId.runtimeType})');
      log('   - senderId: $senderId (${senderId.runtimeType})');
      log('   - messageType: $messageType');
      log('   - content: $content');

      final entry = Entry(
        id: _safeParseInt(id),
        chatId: _safeParseInt(chatId),
        senderId: _safeParseInt(senderId),
        messageType: messageType?.toString(),
        content: content?.toString(),
        createdAt: createdAt?.toString(),
        type: type?.toString(),
        typeValue: _safeParseInt(typeValue),
        thread: thread?.toString(),
        otherDetails1: otherDetails1,
        pinned: pinned,
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

  int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
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

  Future<void> _safeInvoke(String method, {List<Object>? args}) async {
    if (!_isConnected || _hubConnection == null) {
      log('⚠️ Cannot invoke "$method" — not connected');
      return;
    }
    try {
      await _hubConnection!.invoke(method, args: args);
    } catch (e) {
      log('❌ Error invoking "$method": $e');
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
        try {
          await _hubConnection!.invoke(
            'LeaveBranchGroup',
            args: [_currentChatId!],
          );
          log('✅ SignalR: Left previous chat group: $_currentChatId');
        } catch (e) {
          log('⚠️ Error leaving previous group: $e');
        }
      }

      log('🔄 SignalR: Joining group: $chatId');
      await _hubConnection!.invoke('JoinBranchGroup', args: [chatId]);
      _currentChatId = chatId;
      log('✅ SignalR: Joined chat group: $chatId');

      if (isComingBackFromInactivity) {
        log(
          '🔄 User coming back from inactivity, requesting recent messages...',
        );
      }
    } catch (error) {
      log('❌ SignalR: Error joining chat group: $error');
      onError?.call(error is Exception ? error : Exception(error.toString()));
    }
  }

  Future<void> leaveChatGroup(String chatId) async {
    if (!isConnected) {
      log('⚠️ Cannot leave group - SignalR not connected');
      return;
    }

    try {
      log('🔄 Leaving chat group: $chatId');
      await _hubConnection!.invoke('LeaveGroup', args: [chatId]);
      if (_currentChatId == chatId) {
        _currentChatId = null;
      }
      log('✅ Successfully left chat group: $chatId');
    } catch (e) {
      log('❌ Failed to leave chat group $chatId: $e');
    }
  }

  Future<void> requestMissedMessages(
    String chatId,
    String lastTimestamp,
  ) async {
    if (!isConnected) {
      log('⚠️ Not connected, skipping missed messages request');
      return;
    }
    try {
      await _hubConnection!.invoke(
        'RequestMissedMessages',
        args: [chatId, lastTimestamp],
      );
      log('✅ Missed messages request sent');
    } catch (e) {
      log('⚠️ Server does not support RequestMissedMessages: $e');
    }
  }

  Future<void> sendPing() async {
    if (!isConnected) {
      log('⚠️ Cannot ping - not connected');
      return;
    }

    try {
      await _safeInvoke('Ping');
      log('✅ SignalR ping successful');
    } catch (e) {
      log('❌ SignalR ping failed: $e');
    }
  }

  void printConnectionInfo() {
    log('🔍 SignalR Connection Info:');
    log('  - Connected: $_isConnected');
    log('  - Connecting: $_isConnecting');
    log('  - Current Chat: $_currentChatId');
    log('  - Connection ID: ${_hubConnection?.connectionId ?? "null"}');
    log('  - Connection State: ${_hubConnection?.state ?? "null"}');
  }

  Future<void> disconnect() async {
    _isConnecting = false;

    if (_hubConnection != null) {
      try {
        if (_currentChatId != null) {
          await leaveChatGroup(_currentChatId!);
        }
        await _hubConnection!.stop();
        log('✅ SignalR: Disconnected successfully');
      } catch (e) {
        log('⚠️ SignalR: Error during disconnect: $e');
      }
    }

    _isConnected = false;
    _currentChatId = null;
    _hubConnection = null;
    _activityTimer?.cancel();
    _connectionCompleter = null;
  }

  Future<void> reconnect() async {
    log('🔄 Initiating manual reconnection...');
    await disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await initializeConnection();
  }

  Future<bool> checkConnectionHealth() async {
    if (!_isConnected) return false;

    try {
      await sendPing();
      return true;
    } catch (e) {
      log('❌ Connection health check failed: $e');
      return false;
    }
  }

  void startHealthMonitoring() {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      if (_isConnected) {
        final isHealthy = await checkConnectionHealth();
        if (!isHealthy) {
          log('⚠️ Connection unhealthy, attempting reconnect...');
          reconnect().catchError((e) {
            log('❌ Health check reconnect failed: $e');
          });
        }
      }
    });
  }

  Future<void> forceReset() async {
    log('🔄 Force resetting entire SignalR service');
    _connectionTimeoutTimer?.cancel();
    _activityTimer?.cancel();
    _connectionAttempts = 0;
    await _forceResetConnectionState();
    log('✅ SignalR service force reset complete');
  }

  void unawaited(Future<void> future) {
    future.catchError((error) {
      log('Unawaited future error: $error');
    });
  }
}
