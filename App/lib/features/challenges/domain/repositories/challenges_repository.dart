import 'package:sapit/features/challenges/domain/entities/challenge.dart';
import 'package:sapit/features/challenges/domain/entities/challenge_progress.dart';

abstract class ChallengesRepository {
  Future<List<Challenge>> getAllChallenges();
  Future<Challenge> getChallengeById(String id);
  Future<ChallengeProgress> joinChallenge(String challengeId);
  Future<List<ChallengeProgress>> getUserChallenges();
}

