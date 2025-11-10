import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/services/websocket_service.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/chat/data/models/message_model.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_event.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_state.dart';
import 'package:sapit/features/chat/presentation/widgets/message_bubble.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_event.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_state.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatGroup group;

  const ChatMessagesScreen({super.key, required this.group});

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _webSocketService = WebSocketService();

  late ChatBloc _chatBloc;
  late FriendsBloc _friendsBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _chatBloc = context.read<ChatBloc>();
    _friendsBloc = context.read<FriendsBloc>();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await AuthStorage.getUserId();
    if (!mounted) return;

    // Connect WebSocket and join group
    _chatBloc.add(ConnectWebSocketEvent(_currentUserId!));
    _chatBloc.add(LoadMessagesEvent(groupId: widget.group.id));
    _chatBloc.add(JoinGroupEvent(groupId: widget.group.id));

    // Add listener for new messages
    _webSocketService.onNewMessage(_handleNewMessage);
  }

  void _handleNewMessage(dynamic data) {
    try {
      final message = MessageModel.fromJson(data as Map<String, dynamic>);
      _chatBloc.add(NewMessageReceivedEvent(message: message));
    } catch (e) {
      print('Error parsing new message: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUserId == null) return;

    if (state == AppLifecycleState.paused) {
      _chatBloc.add(DisconnectWebSocketEvent());
      _webSocketService.offNewMessage();
    } else if (state == AppLifecycleState.resumed) {
      _chatBloc.add(ConnectWebSocketEvent( _currentUserId!));
      _webSocketService.onNewMessage(_handleNewMessage);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only leave WebSocket room, don't call API to leave group
    _chatBloc.add(LeaveWebSocketGroupEvent(groupId: widget.group.id));
    _webSocketService.offNewMessage();

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _currentUserId == null) return;

    _chatBloc.add(SendMessageEvent(
      userId: _currentUserId!,
      groupId: widget.group.id,
      content: content,
    ));
    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is MessagesLoaded) _scrollToBottom();
              },
              builder: (context, state) {
                if (state is ChatLoading) return const Center(child: CircularProgressIndicator());

                if (state is MessagesLoaded && state.groupId == widget.group.id) {
                  final messages = state.messages;
                  if (messages.isEmpty) return const Center(child: Text('No messages yet'));

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == _currentUserId;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        onLongPress: !isMe && message.sender != null
                            ? () => _showMessageContextMenu(context, message)
                            : null,
                      );
                    },
                  );
                }

                return const Center(child: Text('Loading messages...'));
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _showMessageContextMenu(BuildContext context, Message message) {
    if (message.sender == null) return;

    // Check if user is already a friend
    final friendsState = _friendsBloc.state;
    bool isFriend = false;
    if (friendsState is FriendsLoaded) {
      isFriend = friendsState.friends.any((friend) => friend.id == message.sender!.id);
    }

    if (isFriend) {
      // Find and open private chat
      _openPrivateChat(context, message.sender!.id);
    } else {
      // Show friend request menu
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Send Friend Request'),
                onTap: () {
                  Navigator.pop(context);
                  _sendFriendRequest(context, message.sender!.id);
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _openPrivateChat(BuildContext context, String friendId) async {
    // Get friend's info to match with group name
    final friendsState = _friendsBloc.state;
    String? friendName;
    
    if (friendsState is FriendsLoaded) {
      final friend = friendsState.friends.firstWhere(
        (f) => f.id == friendId,
        orElse: () => throw StateError('Friend not found'),
      );
      friendName = friend.displayName;
    } else {
      // Load friends if not loaded
      _friendsBloc.add(const LoadFriendsEvent());
      await Future.delayed(const Duration(milliseconds: 300));
      final newFriendsState = _friendsBloc.state;
      if (newFriendsState is FriendsLoaded) {
        try {
          final friend = newFriendsState.friends.firstWhere((f) => f.id == friendId);
          friendName = friend.displayName;
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Friend information not found.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }
    }

    if (friendName == null) return;

    // Find the private chat group between current user and friend
    final chatState = _chatBloc.state;
    ChatGroup? privateChat;

    if (chatState is GroupsLoaded) {
      try {
        privateChat = chatState.groups.firstWhere(
          (group) {
            if (group.type != GroupType.PRIVATE) return false;
            // Private chats are named "User1 & User2", check if friend's name is in it
            return group.name.contains(friendName!);
          },
        );
      } catch (_) {
        // Not found in current state
      }
    }

    // If we can't find it in current state, reload groups first
    if (privateChat == null) {
      _chatBloc.add(const LoadGroupsEvent());
      // Wait a bit for groups to load, then try again
      await Future.delayed(const Duration(milliseconds: 500));
      final newState = _chatBloc.state;
      if (newState is GroupsLoaded) {
        try {
          privateChat = newState.groups.firstWhere(
            (group) {
              if (group.type != GroupType.PRIVATE) return false;
              return group.name.contains(friendName!);
            },
          );
        } catch (_) {
          // No private chat found
        }
      }
    }

    if (privateChat != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatMessagesScreen(group: privateChat!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Private chat not found. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _sendFriendRequest(BuildContext context, String userId) {
    context.read<FriendsBloc>().add(SendFriendRequestEvent(userId: userId));
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Friend request sent!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Type a message...'),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
