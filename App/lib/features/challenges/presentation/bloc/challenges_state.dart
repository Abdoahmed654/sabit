import 'package:equatable/equatable.dart';
import 'package:sapit/features/challenges/domain/entities/challenge.dart';
import 'package:sapit/features/challenges/domain/entities/challenge_progress.dart';

abstract class ChallengesState extends Equatable {
  const ChallengesState();

  @override
  List<Object?> get props => [];
}

class ChallengesInitial extends ChallengesState {
  const ChallengesInitial();
}

class ChallengesLoading extends ChallengesState {
  const ChallengesLoading();
}

class ChallengesLoaded extends ChallengesState {
  final List<Challenge> challenges;
  final List<ChallengeProgress> userChallenges;

  const ChallengesLoaded({
    this.challenges = const [],
    this.userChallenges = const [],
  });

  ChallengesLoaded copyWith({
    List<Challenge>? challenges,
    List<ChallengeProgress>? userChallenges,
  }) {
    return ChallengesLoaded(
      challenges: challenges ?? this.challenges,
      userChallenges: userChallenges ?? this.userChallenges,
    );
  }

  @override
  List<Object?> get props => [challenges, userChallenges];
}

class ChallengeDetailLoaded extends ChallengesState {
  final Challenge challenge;

  const ChallengeDetailLoaded(this.challenge);

  @override
  List<Object?> get props => [challenge];
}

class ChallengeJoined extends ChallengesState {
  final ChallengeProgress progress;

  const ChallengeJoined(this.progress);

  @override
  List<Object?> get props => [progress];
}

class ChallengesError extends ChallengesState {
  final String message;

  const ChallengesError(this.message);

  @override
  List<Object?> get props => [message];
}

