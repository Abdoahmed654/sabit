import 'package:sapit/features/challenges/data/datasources/challenges_remote_datasource.dart';
import 'package:sapit/features/challenges/domain/entities/challenge.dart';
import 'package:sapit/features/challenges/domain/entities/challenge_progress.dart';
import 'package:sapit/features/challenges/domain/repositories/challenges_repository.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDataSource remoteDataSource;

  ChallengesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Challenge>> getAllChallenges() async {
    return await remoteDataSource.getAllChallenges();
  }

  @override
  Future<Challenge> getChallengeById(String id) async {
    return await remoteDataSource.getChallengeById(id);
  }

  @override
  Future<ChallengeProgress> joinChallenge(String challengeId) async {
    return await remoteDataSource.joinChallenge(challengeId);
  }

  @override
  Future<List<ChallengeProgress>> getUserChallenges() async {
    return await remoteDataSource.getUserChallenges();
  }
}

