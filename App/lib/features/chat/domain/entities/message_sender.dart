import 'package:equatable/equatable.dart';

class MessageSender extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;

  const MessageSender({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
}

