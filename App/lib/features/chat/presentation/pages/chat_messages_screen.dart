import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/services/websocket_service.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/chat/data/models/message_model.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_event.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_state.dart';
import 'package:sapit/features/chat/presentation/widgets/message_bubble.dart';

class ChatMessagesScreen extends StatefulWidget {
  final ChatGroup group;

  const ChatMessagesScreen({
    super.key,
    required this.group,
  });

  @override
  State<ChatMessagesScreen> createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _webSocketService = WebSocketService();
  String? _currentUserId;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(LoadMessagesEvent(groupId: widget.group.id));

    // Join the group via WebSocket
    _chatBloc.add(JoinGroupEvent(groupId: widget.group.id));

    // Listen for new messages from WebSocket
    _webSocketService.onNewMessage(_handleNewMessage);
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await AuthStorage.getUserId();
    if (mounted) setState(() {});
  }

  void _handleNewMessage(dynamic data) {
    try {
      final message = MessageModel.fromJson(data as Map<String, dynamic>);
      _chatBloc.add(NewMessageReceivedEvent(message: message));
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing new message: $e');
    }
  }

  @override
  void dispose() {
    // Leave the group and stop listening for messages
    _chatBloc.add(LeaveGroupEvent(groupId: widget.group.id));
    _webSocketService.offNewMessage();

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _currentUserId == null) return;

    _chatBloc.add(
      SendMessageEvent(
        userId: _currentUserId!,
        groupId: widget.group.id,
        content: content,
      ),
    );

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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              _getGroupTypeLabel(widget.group.type),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is MessagesLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MessagesLoaded &&
                    state.groupId == widget.group.id) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to send a message!',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _chatBloc.add(LoadMessagesEvent(groupId: widget.group.id));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    ),
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGroupTypeLabel(GroupType type) {
    switch (type) {
      case GroupType.PUBLIC:
        return 'Public Group';
      case GroupType.PRIVATE:
        return 'Private Group';
      case GroupType.CHALLENGE:
        return 'Challenge Group';
    }
  }
}
