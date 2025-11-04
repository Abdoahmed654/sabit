import 'package:sapit/features/auth/domain/entities/User.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    required super.xp,
    required super.coins,
    required super.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"] as String,
        email: json["email"] as String,
        displayName: json["displayName"] as String,
        avatarUrl: json["avatarUrl"] as String?,
        xp: json["xp"] as int? ?? 0,
        coins: json["coins"] as int? ?? 0,
        level: json["level"] as int? ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "displayName": displayName,
        "avatarUrl": avatarUrl,
        "xp": xp,
        "coins": coins,
        "level": level,
      };
}