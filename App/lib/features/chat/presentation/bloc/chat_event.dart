import 'package:equatable/equatable.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadGroupsEvent extends ChatEvent {
  const LoadGroupsEvent();
}

class LoadMessagesEvent extends ChatEvent {
  final String groupId;
  LoadMessagesEvent({required this.groupId});
}

class SendMessageEvent extends ChatEvent {
  final String userId;
  final String groupId;
  final String content;
  SendMessageEvent({
    required this.userId,
    required this.groupId,
    required this.content,
  });
}

class JoinGroupEvent extends ChatEvent {
  final String groupId;
  JoinGroupEvent({required this.groupId});
}

class LeaveGroupEvent extends ChatEvent {
  final String groupId;
  LeaveGroupEvent({required this.groupId});
}

class NewMessageReceivedEvent extends ChatEvent {
  final Message message;
  NewMessageReceivedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}

class ConnectWebSocketEvent extends ChatEvent {
  final String userId;
  ConnectWebSocketEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DisconnectWebSocketEvent extends ChatEvent {}
