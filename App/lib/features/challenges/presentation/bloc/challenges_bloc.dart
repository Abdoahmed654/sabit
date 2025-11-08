import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_event.dart';
import 'package:sapit/features/challenges/presentation/bloc/challenges_state.dart';

class ChallengesBloc extends Bloc<ChallengesEvent, ChallengesState> {
  final ChallengesRepository repository;

  ChallengesBloc({required this.repository}) : super(const ChallengesInitial()) {
    on<LoadAllChallengesEvent>(_onLoadAllChallenges);
    on<LoadChallengeByIdEvent>(_onLoadChallengeById);
    on<JoinChallengeEvent>(_onJoinChallenge);
    on<LoadUserChallengesEvent>(_onLoadUserChallenges);
  }

  Future<void> _onLoadAllChallenges(
    LoadAllChallengesEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    try {
      final challenges = await repository.getAllChallenges();
      
      if (state is ChallengesLoaded) {
        emit((state as ChallengesLoaded).copyWith(challenges: challenges));
      } else {
        emit(ChallengesLoaded(challenges: challenges));
      }
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onLoadChallengeById(
    LoadChallengeByIdEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    try {
      final challenge = await repository.getChallengeById(event.challengeId);
      emit(ChallengeDetailLoaded(challenge));
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onJoinChallenge(
    JoinChallengeEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    try {
      final progress = await repository.joinChallenge(event.challengeId);
      emit(ChallengeJoined(progress));
      
      // Reload challenges and user challenges
      add(const LoadAllChallengesEvent());
      add(const LoadUserChallengesEvent());
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onLoadUserChallenges(
    LoadUserChallengesEvent event,
    Emitter<ChallengesState> emit,
  ) async {
    try {
      final userChallenges = await repository.getUserChallenges();
      
      if (state is ChallengesLoaded) {
        emit((state as ChallengesLoaded).copyWith(userChallenges: userChallenges));
      } else {
        emit(ChallengesLoaded(userChallenges: userChallenges));
      }
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }
}

