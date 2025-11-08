import 'package:sapit/features/chat/domain/entities/message_sender.dart';

class MessageSenderModel extends MessageSender {
  const MessageSenderModel({
    required super.id,
    required super.displayName,
    super.avatarUrl,
  });

  factory MessageSenderModel.fromJson(Map<String, dynamic> json) {
    return MessageSenderModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }
}

