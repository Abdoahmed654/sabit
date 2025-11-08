import 'package:equatable/equatable.dart';
import 'azkar.dart';

class AzkarCompletion extends Equatable {
  final String id;
  final String userId;
  final String azkarId;
  final int xpEarned;
  final int coinsEarned;
  final DateTime completedAt;
  final Azkar? azkar; // Optional, included when fetching with details

  const AzkarCompletion({
    required this.id,
    required this.userId,
    required this.azkarId,
    required this.xpEarned,
    required this.coinsEarned,
    required this.completedAt,
    this.azkar,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        azkarId,
        xpEarned,
        coinsEarned,
        completedAt,
        azkar,
      ];
}

