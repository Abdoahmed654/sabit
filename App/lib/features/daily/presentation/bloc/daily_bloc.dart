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
}

