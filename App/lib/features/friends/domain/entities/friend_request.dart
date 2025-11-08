import 'package:equatable/equatable.dart';

enum FriendRequestStatus { pending, accepted, blocked }

class FriendRequest extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final UserInfo? user; // The person who sent the request

  const FriendRequest({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
    this.user,
  });

  @override
  List<Object?> get props => [id, userId, friendId, status, createdAt, user];
}

class UserInfo extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String email;
  final int level;
  final int xp;
  final int coins;

  const UserInfo({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.email,
    required this.level,
    required this.xp,
    required this.coins,
  });

  @override
  List<Object?> get props => [id, displayName, avatarUrl, email, level, xp, coins];
}

