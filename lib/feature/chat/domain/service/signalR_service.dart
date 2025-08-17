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

  // ✅ ADD DETAILED LOGGING HELPER
  void _logResponse(String methodName, dynamic arguments) {
    log('🔍 ===== SignalR Response Debug =====');
    log('📡 Method: $methodName');
    log('📊 Arguments type: ${arguments.runtimeType}');
    log(
      '📊 Arguments length: ${arguments is List ? arguments.length : 'Not a list'}',
    );

    if (arguments != null) {
      try {
        // Try to pretty print JSON if possible
        final jsonString = jsonEncode(arguments);
        log('📋 Raw JSON: $jsonString');

        // Also log readable format
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
    String baseUrl =
        "http://20.244.37.96:5002/api/chatsHub?userName=${user?.result?.userName ?? ''}";

    if (_hubConnection != null && _isConnected) {
      log('SignalR: Already connected');
      return;
    }

    try {
      await _attemptConnection(
        token ?? '',
        baseUrl,
        HttpTransportType.WebSockets,
      );
    } catch (e) {
      log('SignalR: WebSockets failed, trying LongPolling: $e');
      try {
        await _attemptConnection(
          token ?? '',
          baseUrl,
          HttpTransportType.LongPolling,
        );
      } catch (e2) {
        log('SignalR: All connection attempts failed: $e2');
        onError?.call(e2 is Exception ? e2 : Exception(e2.toString()));
        rethrow;
      }
    }
  }

  Future<void> _attemptConnection(
    String token,
    String baseUrl,
    HttpTransportType transport,
  ) async {
    log('SignalR: Attempting connection with transport: $transport');
    log('SignalR: Using token: ${token.isNotEmpty ? "Present" : "Missing"}');
    log('SignalR: Token length: ${token.length}');
    if (token.isNotEmpty) {
      log('SignalR: Token starts with: ${token.substring(0, 20)}...');
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          baseUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async {
              log(
                'SignalR: Providing access token: ${token.substring(0, 20)}...',
              );
              return token;
            },
            transport: transport,
            skipNegotiation: transport == HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect(retryDelays: [2000, 5000, 10000, 20000])
        .build();

    _setupEventHandlers();

    try {
      log('SignalR: Starting connection...');
      await _hubConnection?.start();
      _isConnected = true;
      log('SignalR: ✅ Connected successfully with $transport');
      onConnected?.call();
    } catch (error) {
      _isConnected = false;
      log('SignalR: ❌ Connection failed with $transport: $error');

      if (error.toString().contains('401')) {
        log('SignalR: 🔒 Authentication failed - token issue detected');
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
    });

    _hubConnection?.onclose(({Exception? error}) {
      _isConnected = false;
      log('SignalR: Connection closed. Error: $error');
      onDisconnected?.call();
    });

    _setupMessageHandlers();
  }

  void _setupMessageHandlers() {
    // ✅ LISTEN TO ALL EVENTS AND LOG THEM
    final allPossibleMethods = [
      'ReceiveMessage',
      'ReceiveChatEntry',
      'ReceiveNewEntries',
      'ReceiveEntryUpdate',
      'ReceiveEntryDeletion',
      'ReceiveTypingStatus',
      'NewMessage',
      'MessageReceived',
      'ChatEntryReceived',
      'EntryAdded',
      'EntryUpdated',
      'EntryDeleted',
      'BroadcastMessage',
      'SendMessage',
      'UpdateEntry',
      'DeleteEntry',
      'UserJoined',
      'UserLeft',
      // ✅ ADD MORE POSSIBLE SERVER METHODS
      'NotifyNewMessage',
      'NotifyEntryUpdate',
      'ChatUpdated',
      'MessageSent',
      'EntryReceived',
      'DataReceived',
    ];

    // ✅ SET UP LISTENERS FOR ALL POSSIBLE METHODS
    for (String methodName in allPossibleMethods) {
      _hubConnection?.on(methodName, (arguments) {
        log('🎯 SignalR: Method "$methodName" called!');
        _logResponse(methodName, arguments);
        _handleGenericResponse(methodName, arguments);
      });
    }

    // ✅ UNIVERSAL LISTENER
    _hubConnection?.on('*', (arguments) {
      log('🌟 SignalR: CATCH-ALL triggered with: $arguments');
      _logResponse('CATCH_ALL', arguments);
    });

    log(
      '✅ SignalR: Set up listeners for ${allPossibleMethods.length} possible methods',
    );
  }

  // ✅ ADD TEST METHOD TO TRIGGER SERVER RESPONSES
  Future<void> testServerMethods() async {
    if (!_isConnected || _hubConnection == null) {
      log('❌ Cannot test - not connected');
      return;
    }

    log('🧪 Testing server methods...');

    final testMethods = [
      'Ping',
      'Echo',
      'Test',
      'GetChatEntry',
      'RequestChatEntry',
      'JoinBranchGroup',
      'SendMessage',
      'GetAllChats',
      'SubscribeToChat',
      'RequestUpdates',
    ];

    for (String method in testMethods) {
      try {
        log('🧪 Testing method: $method');
        await _hubConnection!.invoke(
          method,
          args: [_currentChatId ?? 'test', 'test_user'],
        );
        log('✅ Method $method called successfully');
        await Future.delayed(Duration(milliseconds: 500)); // Wait for response
      } catch (e) {
        log('❌ Method $method failed: $e');
      }
    }
  }

  // ✅ GENERIC RESPONSE HANDLER
  void _handleGenericResponse(String methodName, dynamic arguments) {
    try {
      log('🔧 Processing SignalR method: $methodName');

      switch (methodName.toLowerCase()) {
        case 'receivemessage':
        case 'newmessage':
        case 'messagereceived':
        case 'broadcastmessage':
          log('📨 Handling ReceiveMessage as new chat entry');

          // ✅ FIXED: Only call the correct handler
          log('📨 Handling ReceiveMessage as new chat entry');
          _handleReceiveMessageAsEntry(arguments);
          break;

        case 'receivechatentry':
        case 'chatentryreceived':
          _handleChatEntryResponse(arguments);
          break;

        case 'receivenewentries':
        case 'entryadded':
          _handleNewEntriesResponse(arguments);
          break;

        case 'receiveentryupdate':
        case 'entryupdated':
        case 'updateentry':
          _handleEntryUpdateResponse(arguments);
          break;

        case 'receiveentrydeletion':
        case 'entrydeleted':
        case 'deleteentry':
          _handleEntryDeletionResponse(arguments);
          break;

        case 'receivetypingstatus':
          _handleTypingStatusResponse(arguments);
          break;

        default:
          log(
            '🤷‍♂️ SignalR: Unknown method "$methodName" - no specific handler',
          );
      }
    } catch (e) {
      log('❌ SignalR: Error in generic response handler: $e');
    }
  }

  void _handleChatEntryResponse(dynamic arguments) {
    log('📨 Processing ChatEntry response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final chatEntryData = arguments[0];

        if (chatEntryData is Map<String, dynamic>) {
          log('✅ SignalR: Valid chat entry data structure');
          final chatEntry = ChatEntryResponse.fromJson(chatEntryData);
          log('✅ SignalR: Chat entry parsed successfully');
          onChatEntryReceived?.call(chatEntry);
        } else if (chatEntryData is String) {
          // Try to parse JSON string
          final jsonData = jsonDecode(chatEntryData) as Map<String, dynamic>;
          final chatEntry = ChatEntryResponse.fromJson(jsonData);
          log('✅ SignalR: Chat entry parsed from JSON string');
          onChatEntryReceived?.call(chatEntry);
        } else {
          log(
            '❌ SignalR: Invalid chat entry format: ${chatEntryData.runtimeType}',
          );
        }
      } catch (e) {
        log('❌ SignalR: Error parsing chat entry: $e');
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

  Future<void> testServerConnection() async {
    if (!_isConnected || _hubConnection == null) {
      log('❌ Cannot test - not connected');
      return;
    }

    log('🧪 Testing basic server connection...');

    // Test simple methods that might exist
    final testMethods = ['Ping', 'Echo', 'Test'];

    for (String method in testMethods) {
      try {
        await _hubConnection!.invoke(method, args: []);
        log('✅ Method $method works!');
      } catch (e) {
        log('❌ Method $method failed: $e');
      }
    }
  }

  void _handleReceiveMessageAsEntry(dynamic arguments) {
    log('📨 Processing ReceiveMessage as new chat entry...');

    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      try {
        final messageData = arguments[0];

        // Handle JSON string format (what your server sends)
        Map<String, dynamic> parsedData;
        if (messageData is String) {
          log('🔄 Parsing JSON string message data');
          parsedData = jsonDecode(messageData) as Map<String, dynamic>;
        } else if (messageData is Map<String, dynamic>) {
          log('🔄 Using Map message data');
          parsedData = messageData;
        } else {
          log(
            '❌ SignalR: Invalid ReceiveMessage format: ${messageData.runtimeType}',
          );
          return;
        }

        log('✅ SignalR: Successfully parsed message data');
        log(
          '📊 Message details: ID=${parsedData['Id']}, ChatId=${parsedData['ChatId']}, Content="${parsedData['Content']}"',
        );
        log('📊 Message type: ${parsedData['MessageType']}');

        // ✅ ENHANCED: Handle ChatMedias properly
        List<ChatMedias>? chatMedias;
        if (parsedData['ChatMedias'] != null &&
            parsedData['ChatMedias'] is List) {
          final mediaList = parsedData['ChatMedias'] as List;
          if (mediaList.isNotEmpty) {
            log('📎 Processing ${mediaList.length} media attachments');
            chatMedias = [];

            for (var mediaJson in mediaList) {
              try {
                if (mediaJson is Map<String, dynamic>) {
                  final media = ChatMedias.fromJson(mediaJson);
                  chatMedias.add(media);
                  log(
                    '📎 Media parsed: ID=${media.id}, Type=${media.mediaType}, URL=${media.mediaUrl?.substring(0, 50)}...',
                  );
                }
              } catch (e) {
                log('❌ Error parsing individual media: $e');
              }
            }

            log('✅ Successfully parsed ${chatMedias.length} media items');
          }
        } else {
          log('ℹ️ No media attachments in this message');
        }

        // ✅ ENHANCED: Handle Sender information
        Sender? sender;
        if (parsedData['Sender'] != null &&
            parsedData['Sender'] is Map<String, dynamic>) {
          try {
            sender = Sender.fromJson(
              parsedData['Sender'] as Map<String, dynamic>,
            );
            log('👤 Sender: ${sender.name}');
          } catch (e) {
            log('❌ Error parsing sender: $e');
          }
        }

        // Convert to Entry object with all fields
        final newEntry = Entry(
          id: parsedData['Id'],
          chatId: parsedData['ChatId'],
          senderId: parsedData['SenderId'],
          messageType: parsedData['MessageType'],
          content: parsedData['Content'],
          createdAt: parsedData['CreatedAt'],
          type: parsedData['Type'],
          typeValue: parsedData['TypeValue'],
          thread: parsedData['Thread'],
          pinned: parsedData['Pinned'],

          // ✅ IMPORTANT: Include media and sender
          chatMedias: chatMedias,
          sender: sender,
        );

        log('✅ SignalR: Created Entry object with:');
        log('   - Media items: ${newEntry.chatMedias?.length ?? 0}');
        log('   - Message type: ${newEntry.messageType}');
        log('   - Content: ${newEntry.content}');

        // Log each media item for debugging
        if (newEntry.chatMedias?.isNotEmpty == true) {
          for (var media in newEntry.chatMedias!) {
            log(
              '   📎 Media ID: ${media.id}, Type: ${media.mediaType}, Has URL: ${media.mediaUrl != null}',
            );
          }
        }

        log('📤 Sending to onNewEntriesReceived handler');

        // Call the new entries handler with a single entry
        onNewEntriesReceived?.call([newEntry]);
      } catch (e) {
        log('❌ SignalR: Error parsing ReceiveMessage: $e');
        // log('❌ SignalR: Raw message data: ${messageData}');
        log('❌ SignalR: Stack trace: ${e.toString()}');
      }
    } else {
      log('⚠️ SignalR: Invalid ReceiveMessage arguments format');
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

  // ✅ ENHANCED: Better message response handling
  void _handleMessageResponse(dynamic arguments) {
    log('📨 Processing generic message response...');
    if (arguments != null && arguments is List && arguments.isNotEmpty) {
      final message = arguments[0];
      log('✅ SignalR: Message extracted: $message');

      // Handle both simple messages and chat entry messages
      if (message is String &&
          (message.contains('"Id":') || message.contains('"ChatId":'))) {
        // This looks like a chat entry JSON, handle as new entry
        log(
          '🔄 SignalR: Message contains chat entry data, processing as new entry...',
        );
        _handleReceiveMessageAsEntry(arguments);
      } else {
        // Regular message
        onMessageReceived?.call(message);
      }
    } else {
      log('⚠️ SignalR: Invalid message arguments');
    }
  }
  // Future<void> requestChatEntry(String chatId, String userId) async {
  //   if (!_isConnected || _hubConnection == null) {
  //     log('SignalR: Cannot request chat entry - not connected');
  //     return;
  //   }

  //   try {
  //     log(
  //       '📡 SignalR: Sending RequestChatEntry for chat: $chatId, user: $userId',
  //     );
  //     await _hubConnection!.invoke('RequestChatEntry', args: [chatId, userId]);
  //     log('✅ SignalR: RequestChatEntry sent successfully');
  //   } catch (error) {
  //     log('❌ SignalR: Error requesting chat entry: $error');
  //     onError?.call(error is Exception ? error : Exception(error.toString()));
  //   }
  // }

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

  // ✅ ADD MANUAL TEST METHODS
  Future<void> testAllMethods() async {
    if (!_isConnected || _hubConnection == null) {
      log('❌ Cannot test - not connected');
      return;
    }

    final testMethods = [
      'GetChatEntry',
      'RequestChatEntry',
      'JoinBranchGroup',
      'SendMessage',
      'GetAllChats',
      'Ping',
    ];

    for (String method in testMethods) {
      try {
        log('🧪 Testing method: $method');
        await _hubConnection!.invoke(method, args: ['test']);
        log('✅ Method $method called successfully');
      } catch (e) {
        log('❌ Method $method failed: $e');
      }
    }
  }

  void printConnectionInfo() {
    log('🔍 SignalR Connection Info:');
    log('  - Connected: $_isConnected');
    log('  - Current Chat: $_currentChatId');
    log('  - Connection ID: ${_hubConnection?.connectionId ?? "null"}');
    log('  - Connection State: ${_hubConnection?.state ?? "null"}');
  }
}
