import 'package:equatable/equatable.dart';

enum GroupType {
  PUBLIC,
  PRIVATE,
  CHALLENGE,
}

class GroupMember extends Equatable {
  final String id;
  final String userId;
  final String? displayName;
  final String? avatarUrl;

  const GroupMember({
    required this.id,
    required this.userId,
    this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, userId, displayName, avatarUrl];
}

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final GroupType type;
  final DateTime createdAt;
  final List<GroupMember>? members;

  const ChatGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.members,
  });

  @override
  List<Object?> get props => [id, name, type, createdAt, members];
}

