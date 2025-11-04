import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int xp;
  final int coins;
  final int level;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    required this.xp,
    required this.coins,
    required this.level,
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, xp, coins, level];
}