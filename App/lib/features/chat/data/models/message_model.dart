import 'package:sapit/features/chat/data/models/message_sender_model.dart';
import 'package:sapit/features/chat/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] != null
          ? MessageSenderModel.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'sender': sender != null
          ? MessageSenderModel(
              id: sender!.id,
              displayName: sender!.displayName,
              avatarUrl: sender!.avatarUrl,
            ).toJson()
          : null,
    };
  }
}

