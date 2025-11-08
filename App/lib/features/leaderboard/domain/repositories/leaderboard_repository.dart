import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/leaderboard/domain/entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> getXpLeaderboard({int limit = 100});
  Future<Either<Failure, List<LeaderboardEntry>>> getCoinsLeaderboard({int limit = 100});
  Future<Either<Failure, List<LeaderboardEntry>>> getFriendsLeaderboard(String type);
}

