import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_groups.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_group.dart';
import 'package:sapit/features/daily/domain/usecases/complete_azkar.dart';
import 'package:sapit/features/daily/domain/usecases/get_azkar_completions.dart';
import 'package:sapit/features/daily/domain/usecases/complete_fasting.dart';
import 'package:sapit/features/daily/domain/usecases/get_fasting_status.dart';
import 'good_deeds_event.dart';
import 'good_deeds_state.dart';

class GoodDeedsBloc extends Bloc<GoodDeedsEvent, GoodDeedsState> {
  final GetAzkarGroups getAzkarGroups;
  final GetAzkarGroup getAzkarGroup;
  final CompleteAzkar completeAzkar;
  final GetAzkarCompletions getAzkarCompletions;
  final CompleteFasting completeFasting;
  final GetFastingStatus getFastingStatus;

  GoodDeedsBloc({
    required this.getAzkarGroups,
    required this.getAzkarGroup,
    required this.completeAzkar,
    required this.getAzkarCompletions,
    required this.completeFasting,
    required this.getFastingStatus,
  }) : super(GoodDeedsInitial()) {
    on<LoadAzkarGroupsEvent>(_onLoadAzkarGroups);
    on<LoadAzkarGroupEvent>(_onLoadAzkarGroup);
    on<CompleteAzkarEvent>(_onCompleteAzkar);
    on<LoadAzkarCompletionsEvent>(_onLoadAzkarCompletions);
    on<CompleteFastingEvent>(_onCompleteFasting);
    on<LoadFastingStatusEvent>(_onLoadFastingStatus);
  }

  Future<void> _onLoadAzkarGroups(
    LoadAzkarGroupsEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      emit(GoodDeedsLoading());
      final groups = await getAzkarGroups(category: event.category);
      final completions = await getAzkarCompletions();
      emit(AzkarGroupsLoaded(groups: groups, completions: completions));
    } catch (e) {
      emit(GoodDeedsError(e.toString()));
    }
  }

  Future<void> _onLoadAzkarGroup(
    LoadAzkarGroupEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      emit(GoodDeedsLoading());
      final group = await getAzkarGroup(event.groupId);
      final completions = await getAzkarCompletions(groupId: event.groupId);
      emit(AzkarGroupLoaded(group: group, completions: completions));
    } catch (e) {
      emit(GoodDeedsError(e.toString()));
    }
  }

  Future<void> _onCompleteAzkar(
    CompleteAzkarEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      final result = await completeAzkar(event.azkarId);
      final rewards = result['rewards'] as Map<String, dynamic>;
      emit(AzkarCompleted(
        xpEarned: rewards['xp'] as int,
        coinsEarned: rewards['coins'] as int,
      ));

      // Reload azkar groups and completions after completing azkar
      add(const LoadAzkarGroupsEvent());
    } catch (e) {
      emit(GoodDeedsError(e.toString()));

      // Reload azkar groups even on error to restore the UI
      add(const LoadAzkarGroupsEvent());
    }
  }

  Future<void> _onLoadAzkarCompletions(
    LoadAzkarCompletionsEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      final completions = await getAzkarCompletions(groupId: event.groupId);
      emit(AzkarCompletionsLoaded(completions));
    } catch (e) {
      emit(GoodDeedsError(e.toString()));
    }
  }

  Future<void> _onCompleteFasting(
    CompleteFastingEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      final result = await completeFasting(event.fastingType);
      final rewards = result['rewards'] as Map<String, dynamic>;
      emit(FastingCompleted(
        xpEarned: rewards['xp'] as int,
        coinsEarned: rewards['coins'] as int,
      ));

      // Reload azkar groups after completing fasting
      add(const LoadAzkarGroupsEvent());
    } catch (e) {
      emit(GoodDeedsError(e.toString()));

      // Reload azkar groups even on error to restore the UI
      add(const LoadAzkarGroupsEvent());
    }
  }

  Future<void> _onLoadFastingStatus(
    LoadFastingStatusEvent event,
    Emitter<GoodDeedsState> emit,
  ) async {
    try {
      final status = await getFastingStatus();
      emit(FastingStatusLoaded(status));
    } catch (e) {
      emit(GoodDeedsError(e.toString()));
    }
  }
}

