import 'package:dartz/dartz.dart';
import 'package:sapit/core/error/failures.dart';
import 'package:sapit/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import 'package:sapit/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:sapit/features/leaderboard/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getXpLeaderboard({int limit = 100}) async {
    try {
      final entries = await remoteDataSource.getXpLeaderboard(limit: limit);
      return Right(entries);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getCoinsLeaderboard({int limit = 100}) async {
    try {
      final entries = await remoteDataSource.getCoinsLeaderboard(limit: limit);
      return Right(entries);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getFriendsLeaderboard(String type) async {
    try {
      final entries = await remoteDataSource.getFriendsLeaderboard(type);
      return Right(entries);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

