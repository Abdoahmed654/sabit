import 'package:equatable/equatable.dart';
import 'package:sapit/features/daily/domain/entities/daily_action.dart';
import 'package:sapit/features/daily/domain/entities/daily_quote.dart';
import 'package:sapit/features/daily/domain/entities/prayer_times.dart';

abstract class DailyState extends Equatable {
  const DailyState();

  @override
  List<Object?> get props => [];
}

class DailyInitial extends DailyState {
  const DailyInitial();
}

class DailyLoading extends DailyState {
  const DailyLoading();
}

class DailyLoaded extends DailyState {
  final DailyQuote? quote;
  final PrayerTimes? prayerTimes;
  final List<DailyAction> todayActions;
  final List<DailyAction> userActions;
  final List<String> completedPrayers;
  final List<String> remainingPrayers;

  const DailyLoaded({
    this.quote,
    this.prayerTimes,
    this.todayActions = const [],
    this.userActions = const [],
    this.completedPrayers = const [],
    this.remainingPrayers = const [],
  });

  DailyLoaded copyWith({
    DailyQuote? quote,
    PrayerTimes? prayerTimes,
    List<DailyAction>? todayActions,
    List<DailyAction>? userActions,
    List<String>? completedPrayers,
    List<String>? remainingPrayers,
  }) {
    return DailyLoaded(
      quote: quote ?? this.quote,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      todayActions: todayActions ?? this.todayActions,
      userActions: userActions ?? this.userActions,
      completedPrayers: completedPrayers ?? this.completedPrayers,
      remainingPrayers: remainingPrayers ?? this.remainingPrayers,
    );
  }

  @override
  List<Object?> get props => [
        quote,
        prayerTimes,
        todayActions,
        userActions,
        completedPrayers,
        remainingPrayers
      ];
}

class DailyError extends DailyState {
  final String message;

  const DailyError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActionRecorded extends DailyState {
  final DailyAction action;

  const ActionRecorded(this.action);

  @override
  List<Object?> get props => [action];
}

class PrayerCompleted extends DailyState {
  final String prayerName;
  final int xpEarned;
  final int coinsEarned;
  final String message;

  const PrayerCompleted({
    required this.prayerName,
    required this.xpEarned,
    required this.coinsEarned,
    this.message = 'Prayer completed successfully!',
  });

  @override
  List<Object?> get props => [prayerName, xpEarned, coinsEarned, message];
}
