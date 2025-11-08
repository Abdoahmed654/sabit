import 'package:equatable/equatable.dart';

enum GroupType {
  PUBLIC,
  PRIVATE,
  CHALLENGE,
}

class ChatGroup extends Equatable {
  final String id;
  final String name;
  final GroupType type;
  final DateTime createdAt;

  const ChatGroup({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, type, createdAt];
}

