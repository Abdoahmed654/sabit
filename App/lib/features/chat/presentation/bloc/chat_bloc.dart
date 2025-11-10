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

  /// Keep track of joined groups
  final Set<String> _joinedGroups = {};

  /// Keep track if WebSocket is connected
  bool _webSocketConnected = false;

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
    on<LeaveWebSocketGroupEvent>(_onLeaveWebSocketGroup);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
    on<CreateGroupEvent>(_onCreateGroup);
    on<AddMemberToGroupEvent>(_onAddMemberToGroup);
    on<RemoveMemberFromGroupEvent>(_onRemoveMemberFromGroup);
  }

  Future<void> _onLoadGroups(LoadGroupsEvent event, Emitter<ChatState> emit) async {
    // Load cached groups first for instant display
    final cachedGroups = await localDataSource.getCachedGroups();
    if (cachedGroups.isNotEmpty) {
      emit(GroupsLoaded(groups: cachedGroups));
    } else {
      emit(ChatLoading());
    }

    // Then fetch from server
    final result = await chatRepository.getAllGroups();

    result.fold(
      (failure) {
        // Only show error if we don't have cached groups
        if (cachedGroups.isEmpty) {
          emit(ChatError(failure.message));
        }
      },
      (groups) => emit(GroupsLoaded(groups: groups)),
    );
  }

  Future<void> _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    // Load cached messages first for instant display
    final cachedMessages = await localDataSource.getCachedMessages(event.groupId);
    if (cachedMessages.isNotEmpty) {
      emit(MessagesLoaded(
        groupId: event.groupId,
        messages: cachedMessages.reversed.toList(),
      ));
    } else {
      emit(ChatLoading());
    }

    // Then fetch from server
    final result = await chatRepository.getMessages(groupId: event.groupId);

    result.fold(
      (failure) {
        // Only show error if we don't have cached messages
        if (cachedMessages.isEmpty) {
          emit(ChatError(failure.message));
        }
      },
      (messages) => emit(MessagesLoaded(groupId: event.groupId, messages: messages)),
    );
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
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

    webSocketService.sendMessage(event.userId, event.groupId, event.content);
  }

  /// Join a group safely: only join if not already joined
  void _onJoinGroup(JoinGroupEvent event, Emitter<ChatState> emit) {
    if (!_joinedGroups.contains(event.groupId)) {
      webSocketService.joinGroup(event.groupId);
      _joinedGroups.add(event.groupId);
    }
  }

  Future<void> _onLeaveGroup(LeaveGroupEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    final result = await leaveGroupUsecase(LeaveGroupParams(event.groupId));

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        if (_joinedGroups.contains(event.groupId)) {
          webSocketService.leaveGroup(event.groupId);
          _joinedGroups.remove(event.groupId);
        }
        emit(const GroupLeft('Successfully left the group'));
        add(const LoadGroupsEvent());
      },
    );
  }

  /// Leave WebSocket room only (no API call) - used when navigating away
  void _onLeaveWebSocketGroup(LeaveWebSocketGroupEvent event, Emitter<ChatState> emit) {
    if (_joinedGroups.contains(event.groupId)) {
      webSocketService.leaveGroup(event.groupId);
      _joinedGroups.remove(event.groupId);
    }
  }

  Future<void> _onNewMessageReceived(NewMessageReceivedEvent event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded && (state as MessagesLoaded).groupId == event.message.groupId) {
      final messages = List<Message>.from((state as MessagesLoaded).messages);

      messages.removeWhere((m) =>
          m.id.startsWith('temp-') &&
          m.content == event.message.content &&
          m.senderId == event.message.senderId);

      messages.add(event.message);

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

  /// Connect WebSocket only once
  void _onConnectWebSocket(ConnectWebSocketEvent event, Emitter<ChatState> emit) {
    if (!_webSocketConnected) {
      webSocketService.connect(event.userId);
      _webSocketConnected = true;

      /// Setup new message listener
      webSocketService.onNewMessage((data) {
        try {
          final message = MessageModel.fromJson(data as Map<String, dynamic>);
          add(NewMessageReceivedEvent(message: message));
        } catch (_) {}
      });

      // Rejoin all previously joined groups
      for (final groupId in _joinedGroups) {
        webSocketService.joinGroup(groupId);
      }
    }
  }

  /// Disconnect WebSocket safely
  void _onDisconnectWebSocket(DisconnectWebSocketEvent event, Emitter<ChatState> emit) {
    if (_webSocketConnected) {
      webSocketService.offNewMessage();
      webSocketService.disconnect();
      _webSocketConnected = false;
      _joinedGroups.clear();
    }
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await chatRepository.createGroup(
      name: event.name,
      memberIds: event.memberIds,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        emit(const GroupCreated('Group created successfully!'));
        add(const LoadGroupsEvent());
      },
    );
  }

  Future<void> _onAddMemberToGroup(AddMemberToGroupEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await chatRepository.addMemberToGroup(event.groupId, event.userId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        emit(const MemberAdded('Member added successfully!'));
        add(const LoadGroupsEvent());
      },
    );
  }

  Future<void> _onRemoveMemberFromGroup(RemoveMemberFromGroupEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    final result = await chatRepository.removeMemberFromGroup(event.groupId, event.memberId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {
        emit(const MemberRemoved('Member removed successfully!'));
        add(const LoadGroupsEvent());
      },
    );
  }
}
