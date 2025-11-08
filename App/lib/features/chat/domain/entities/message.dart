import 'package:equatable/equatable.dart';
import 'package:sapit/features/chat/domain/entities/message_sender.dart';

class Message extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final MessageSender? sender;

  const Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.sender,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        senderId,
        content,
        createdAt,
        sender,
      ];
}

