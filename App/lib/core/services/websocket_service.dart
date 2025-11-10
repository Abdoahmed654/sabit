import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  static const String _baseUrl = 'http://localhost:3000';

  io.Socket? _socket;
  bool _isConnected = false;

  bool _hasNewMessageListener = false;
  bool _hasFriendRequestListener = false;
  bool _hasFriendRequestAcceptedListener = false;

  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_socket != null && _isConnected) return;

    _socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'userId': userId})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('✅ WebSocket connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('❌ WebSocket disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      print('❌ WebSocket connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ WebSocket error: $error');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;

      _hasNewMessageListener = false;
      _hasFriendRequestListener = false;
      _hasFriendRequestAcceptedListener = false;

      print('WebSocket disconnected and disposed');
    }
  }

  // Chat methods
  void joinGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('joinGroup', {'groupId': groupId});
      print('Joined group: $groupId');
    }
  }

  void leaveGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leaveGroup', {'groupId': groupId});
      print('Left group: $groupId');
    }
  }

  void sendMessage(String userId, String groupId, String content) {
    if (_socket != null && _isConnected) {
      _socket!.emit('sendMessage', {
        'userId': userId,
        'groupId': groupId,
        'content': content,
      });
      print('Message sent to group: $groupId');
    }
  }

  // Listeners
  void onNewMessage(Function(dynamic) callback) {
    if (_socket != null && !_hasNewMessageListener) {
      _socket!.on('newMessage', callback);
      _hasNewMessageListener = true;
    }
  }

  void offNewMessage() {
    if (_socket != null && _hasNewMessageListener) {
      _socket!.off('newMessage');
      _hasNewMessageListener = false;
    }
  }

  void onFriendRequest(Function(dynamic) callback) {
    if (_socket != null && !_hasFriendRequestListener) {
      _socket!.on('friendRequest', callback);
      _hasFriendRequestListener = true;
    }
  }

  void offFriendRequest() {
    if (_socket != null && _hasFriendRequestListener) {
      _socket!.off('friendRequest');
      _hasFriendRequestListener = false;
    }
  }

  void onFriendRequestAccepted(Function(dynamic) callback) {
    if (_socket != null && !_hasFriendRequestAcceptedListener) {
      _socket!.on('friendRequestAccepted', callback);
      _hasFriendRequestAcceptedListener = true;
    }
  }

  void offFriendRequestAccepted() {
    if (_socket != null && _hasFriendRequestAcceptedListener) {
      _socket!.off('friendRequestAccepted');
      _hasFriendRequestAcceptedListener = false;
    }
  }
}
