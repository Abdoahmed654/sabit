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

class LeaveWebSocketGroupEvent extends ChatEvent {
  final String groupId;
  LeaveWebSocketGroupEvent({required this.groupId});
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

class CreateGroupEvent extends ChatEvent {
  final String name;
  final List<String>? memberIds;

  CreateGroupEvent({
    required this.name,
    this.memberIds,
  });

  @override
  List<Object?> get props => [name, memberIds];
}

class AddMemberToGroupEvent extends ChatEvent {
  final String groupId;
  final String userId;

  AddMemberToGroupEvent({
    required this.groupId,
    required this.userId,
  });

  @override
  List<Object?> get props => [groupId, userId];
}

class RemoveMemberFromGroupEvent extends ChatEvent {
  final String groupId;
  final String memberId;

  RemoveMemberFromGroupEvent({
    required this.groupId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [groupId, memberId];
}
