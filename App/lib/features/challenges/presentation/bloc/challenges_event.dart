import 'package:equatable/equatable.dart';

abstract class ChallengesEvent extends Equatable {
  const ChallengesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllChallengesEvent extends ChallengesEvent {
  const LoadAllChallengesEvent();
}

class LoadChallengeByIdEvent extends ChallengesEvent {
  final String challengeId;

  const LoadChallengeByIdEvent(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}

class JoinChallengeEvent extends ChallengesEvent {
  final String challengeId;

  const JoinChallengeEvent(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}

class LoadUserChallengesEvent extends ChallengesEvent {
  const LoadUserChallengesEvent();
}

