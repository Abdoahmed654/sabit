import 'package:socket_io_client/socket_io_client.dart' as io;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  static const String _baseUrl = 'http://localhost:3000';

  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String userId) {
    if (_socket != null && _isConnected) {
      // ignore: avoid_print
      print('WebSocket already connected');
      return;
    }

    // ignore: avoid_print
    print('Connecting to WebSocket...');

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
      // ignore: avoid_print
      print('✅ WebSocket connected');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      // ignore: avoid_print
      print('❌ WebSocket disconnected');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      // ignore: avoid_print
      print('❌ WebSocket connection error: $error');
      _isConnected = false;
    });

    _socket!.onError((error) {
      // ignore: avoid_print
      print('❌ WebSocket error: $error');
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      // ignore: avoid_print
      print('WebSocket disconnected and disposed');
    }
  }

  // Chat methods
  void joinGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('joinGroup', {'groupId': groupId});
      // ignore: avoid_print
      print('Joined group: $groupId');
    }
  }

  void leaveGroup(String groupId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leaveGroup', {'groupId': groupId});
      // ignore: avoid_print
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
      // ignore: avoid_print
      print('Message sent to group: $groupId');
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('newMessage', callback);
    }
  }

  void offNewMessage() {
    if (_socket != null) {
      _socket!.off('newMessage');
    }
  }

  // Friend request methods
  void onFriendRequest(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('friendRequest', callback);
    }
  }

  void offFriendRequest() {
    if (_socket != null) {
      _socket!.off('friendRequest');
    }
  }

  void onFriendRequestAccepted(Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on('friendRequestAccepted', callback);
    }
  }

  void offFriendRequestAccepted() {
    if (_socket != null) {
      _socket!.off('friendRequestAccepted');
    }
  }

  // Generic event listener
  void on(String event, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(event, callback);
    }
  }

  void off(String event) {
    if (_socket != null) {
      _socket!.off(event);
    }
  }

  void emit(String event, dynamic data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    }
  }
}

