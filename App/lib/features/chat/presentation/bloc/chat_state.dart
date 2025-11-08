import 'package:equatable/equatable.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class GroupsLoaded extends ChatState {
  final List<ChatGroup> groups;

  const GroupsLoaded({required this.groups});

  @override
  List<Object?> get props => [groups];
}

class MessagesLoaded extends ChatState {
  final String groupId;
  final List<Message> messages;

  const MessagesLoaded({required this.groupId, required this.messages});

  @override
  List<Object?> get props => [groupId, messages];
}

class GroupLeft extends ChatState {
  final String message;
  const GroupLeft(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
