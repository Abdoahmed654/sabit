import 'package:equatable/equatable.dart';

enum FastingType {
  voluntary,
  monday,
  thursday,
  whiteDays,
  arafah,
  ashura,
  shawwal,
}

class FastingCompletion extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final FastingType fastingType;
  final int xpEarned;
  final int coinsEarned;
  final DateTime createdAt;

  const FastingCompletion({
    required this.id,
    required this.userId,
    required this.date,
    required this.fastingType,
    required this.xpEarned,
    required this.coinsEarned,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        fastingType,
        xpEarned,
        coinsEarned,
        createdAt,
      ];
}

class FastingStatus extends Equatable {
  final bool completedToday;
  final bool canSubmit;
  final String? message;
  final FastingCompletion? completion;

  const FastingStatus({
    required this.completedToday,
    required this.canSubmit,
    this.message,
    this.completion,
  });

  @override
  List<Object?> get props => [
        completedToday,
        canSubmit,
        message,
        completion,
      ];
}

