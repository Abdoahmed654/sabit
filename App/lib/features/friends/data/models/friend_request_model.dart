import 'package:sapit/features/friends/domain/entities/friend_request.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.userId,
    required super.friendId,
    required super.status,
    required super.createdAt,
    super.user,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendId: json['friendId'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: json['user'] != null 
          ? UserInfoModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendId': friendId,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      if (user != null) 'user': (user as UserInfoModel).toJson(),
    };
  }

  static FriendRequestStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return FriendRequestStatus.pending;
      case 'ACCEPTED':
        return FriendRequestStatus.accepted;
      case 'BLOCKED':
        return FriendRequestStatus.blocked;
      default:
        return FriendRequestStatus.pending;
    }
  }

  static String _statusToString(FriendRequestStatus status) {
    switch (status) {
      case FriendRequestStatus.pending:
        return 'PENDING';
      case FriendRequestStatus.accepted:
        return 'ACCEPTED';
      case FriendRequestStatus.blocked:
        return 'BLOCKED';
    }
  }
}

class UserInfoModel extends UserInfo {
  const UserInfoModel({
    required super.id,
    required super.displayName,
    super.avatarUrl,
    required super.email,
    required super.level,
    required super.xp,
    required super.coins,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'email': email,
      'level': level,
      'xp': xp,
      'coins': coins,
    };
  }
}

