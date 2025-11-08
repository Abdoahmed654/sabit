import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/core/services/websocket_service.dart';
import 'package:sapit/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:sapit/features/chat/data/models/message_model.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';
import 'package:sapit/features/chat/domain/repositories/chat_repository.dart';
import 'package:sapit/features/chat/domain/usecases/leave_group_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final WebSocketService webSocketService;
  final ChatLocalDataSource localDataSource;
  final LeaveGroupUsecase leaveGroupUsecase;

  ChatBloc({
    required this.chatRepository,
    required this.webSocketService,
    required this.localDataSource,
    required this.leaveGroupUsecase,
  }) : super(ChatInitial()) {
    on<LoadGroupsEvent>(_onLoadGroups);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<JoinGroupEvent>(_onJoinGroup);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
  }

  Future<void> _onLoadGroups(LoadGroupsEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await chatRepository.getAllGroups();

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (groups) => emit(GroupsLoaded(groups: groups)),
    );
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await chatRepository.getMessages(groupId: event.groupId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) => emit(MessagesLoaded(groupId: event.groupId, messages: messages)),
    );
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    // ✅ Step 1: Add optimistic message to UI
    if (state is MessagesLoaded && (state as MessagesLoaded).groupId == event.groupId) {
      final current = List<Message>.from((state as MessagesLoaded).messages);
      final optimistic = Message(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: event.userId,
        groupId: event.groupId,
        content: event.content,
        createdAt: DateTime.now(),
      );
      current.add(optimistic);
      emit(MessagesLoaded(groupId: event.groupId, messages: current));
    }

    // ✅ Step 2: Send via WebSocket (backend will broadcast to all clients)
    webSocketService.sendMessage(event.userId, event.groupId, event.content);
  }

  void _onJoinGroup(JoinGroupEvent event, Emitter<ChatState> emit) {
    webSocketService.joinGroup(event.groupId);
  }

  Future<void> _onLeaveGroup(LeaveGroupEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    final result = await leaveGroupUsecase(LeaveGroupParams(event.groupId));

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        webSocketService.leaveGroup(event.groupId);
        emit(const GroupLeft('Successfully left the group'));
        // Reload groups after leaving
        add(const LoadGroupsEvent());
      },
    );
  }

  Future<void> _onNewMessageReceived(NewMessageReceivedEvent event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded && (state as MessagesLoaded).groupId == event.message.groupId) {
      final messages = List<Message>.from((state as MessagesLoaded).messages);

      // Remove optimistic message if it exists
      messages.removeWhere((m) =>
          m.id.startsWith('temp-') &&
          m.content == event.message.content &&
          m.senderId == event.message.senderId);

      // Add the real message from server
      messages.add(event.message);

      // Update cache with new messages
      final messageModels = messages
          .map((m) => MessageModel(
                id: m.id,
                groupId: m.groupId,
                senderId: m.senderId,
                content: m.content,
                createdAt: m.createdAt,
                sender: m.sender,
              ))
          .toList();
      await localDataSource.cacheMessages(event.message.groupId, messageModels);

      emit(MessagesLoaded(groupId: event.message.groupId, messages: messages));
    }
  }

  void _onConnectWebSocket(ConnectWebSocketEvent event, Emitter<ChatState> emit) {
    webSocketService.connect(event.userId);
  }

  void _onDisconnectWebSocket(DisconnectWebSocketEvent event, Emitter<ChatState> emit) {
    webSocketService.disconnect();
  }
}
