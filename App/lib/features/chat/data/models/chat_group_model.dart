import 'package:sapit/features/chat/domain/entities/chat_group.dart';

class ChatGroupModel extends ChatGroup {
  const ChatGroupModel({
    required super.id,
    required super.name,
    required super.type,
    required super.createdAt,
  });

  factory ChatGroupModel.fromJson(Map<String, dynamic> json) {
    return ChatGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseGroupType(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static GroupType _parseGroupType(String type) {
    switch (type.toUpperCase()) {
      case 'PUBLIC':
        return GroupType.PUBLIC;
      case 'PRIVATE':
        return GroupType.PRIVATE;
      case 'CHALLENGE':
        return GroupType.CHALLENGE;
      default:
        return GroupType.PUBLIC;
    }
  }
}

