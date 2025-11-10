import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sapit/features/daily/domain/repositories/daily_repository.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_event.dart';
import 'package:sapit/features/daily/presentation/bloc/daily_state.dart';

class DailyBloc extends Bloc<DailyEvent, DailyState> {
  final DailyRepository repository;

  DailyBloc({required this.repository}) : super(const DailyInitial()) {
    on<LoadDailyQuoteEvent>(_onLoadDailyQuote);
    on<LoadPrayerTimesEvent>(_onLoadPrayerTimes);
    on<LoadTodayActionsEvent>(_onLoadTodayActions);
    on<LoadUserActionsEvent>(_onLoadUserActions);
    on<RecordActionEvent>(_onRecordAction);
    on<CompletePrayerEvent>(_onCompletePrayer);
    on<LoadTodayPrayersEvent>(_onLoadTodayPrayers);
  }

  Future<void> _onLoadDailyQuote(
    LoadDailyQuoteEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final quote = await repository.getDailyQuote();

      if (state is DailyLoaded) {
        emit((state as DailyLoaded).copyWith(quote: quote));
      } else {
        emit(DailyLoaded(quote: quote));
      }
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimesEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final prayerTimes = await repository.getPrayerTimes(
        latitude: event.latitude,
        longitude: event.longitude,
        date: event.date,
      );

      if (state is DailyLoaded) {
        emit((state as DailyLoaded).copyWith(prayerTimes: prayerTimes));
      } else {
        emit(DailyLoaded(prayerTimes: prayerTimes));
      }
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onLoadTodayActions(
    LoadTodayActionsEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final actions = await repository.getTodayActions();

      if (state is DailyLoaded) {
        emit((state as DailyLoaded).copyWith(todayActions: actions));
      } else {
        emit(DailyLoaded(todayActions: actions));
      }
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onLoadUserActions(
    LoadUserActionsEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final actions = await repository.getUserActions(days: event.days);

      if (state is DailyLoaded) {
        emit((state as DailyLoaded).copyWith(userActions: actions));
      } else {
        emit(DailyLoaded(userActions: actions));
      }
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onRecordAction(
    RecordActionEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final action = await repository.recordAction(
        actionType: event.actionType,
        metadata: event.metadata,
      );

      emit(ActionRecorded(action));

      // Reload today's actions
      add(const LoadTodayActionsEvent());
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onCompletePrayer(
    CompletePrayerEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final result = await repository.completePrayer(
        prayerName: event.prayerName,
        onTime: event.onTime,
      );

      emit(PrayerCompleted(
        prayerName: event.prayerName,
        xpEarned: result['xpEarned'] as int,
        coinsEarned: result['coinsEarned'] as int,
      ));

      // Reload today's prayers
      add(const LoadTodayPrayersEvent());
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }

  Future<void> _onLoadTodayPrayers(
    LoadTodayPrayersEvent event,
    Emitter<DailyState> emit,
  ) async {
    try {
      final result = await repository.getTodayPrayers();
      final completed = (result['completed'] as List)
          .map((e) => e['prayerName'] as String)
          .toList();
      final remaining =
          (result['remaining'] as List).map((e) => e as String).toList();

      if (state is DailyLoaded) {
        emit((state as DailyLoaded).copyWith(
          completedPrayers: completed,
          remainingPrayers: remaining,
        ));
      } else {
        emit(DailyLoaded(
          completedPrayers: completed,
          remainingPrayers: remaining,
        ));
      }
    } catch (e) {
      emit(DailyError(e.toString()));
    }
  }
}
