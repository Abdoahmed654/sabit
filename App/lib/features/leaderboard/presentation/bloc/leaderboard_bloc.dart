import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_event.dart';
import 'package:sapit/features/leaderboard/presentation/bloc/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardBloc({required this.repository}) : super(const LeaderboardInitial()) {
    on<LoadXpLeaderboardEvent>(_onLoadXpLeaderboard);
    on<LoadCoinsLeaderboardEvent>(_onLoadCoinsLeaderboard);
    on<LoadFriendsLeaderboardEvent>(_onLoadFriendsLeaderboard);
  }

  Future<void> _onLoadXpLeaderboard(
    LoadXpLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final result = await repository.getXpLeaderboard(limit: event.limit);
      result.fold(
        (failure) => emit(LeaderboardError(failure.toString())),
        (entries) => emit(LeaderboardLoaded(entries: entries, type: 'xp')),
      );
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onLoadCoinsLeaderboard(
    LoadCoinsLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final result = await repository.getCoinsLeaderboard(limit: event.limit);
      result.fold(
        (failure) => emit(LeaderboardError(failure.toString())),
        (entries) => emit(LeaderboardLoaded(entries: entries, type: 'coins')),
      );
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onLoadFriendsLeaderboard(
    LoadFriendsLeaderboardEvent event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final result = await repository.getFriendsLeaderboard(event.type);
      result.fold(
        (failure) => emit(LeaderboardError(failure.toString())),
        (entries) => emit(LeaderboardLoaded(entries: entries, type: 'friends-${event.type}')),
      );
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}

