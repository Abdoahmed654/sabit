import 'package:equatable/equatable.dart';

abstract class DailyEvent extends Equatable {
  const DailyEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyQuoteEvent extends DailyEvent {
  const LoadDailyQuoteEvent();
}

class LoadPrayerTimesEvent extends DailyEvent {
  final double latitude;
  final double longitude;
  final String? date;

  const LoadPrayerTimesEvent({
    required this.latitude,
    required this.longitude,
    this.date,
  });

  @override
  List<Object?> get props => [latitude, longitude, date];
}

class LoadTodayActionsEvent extends DailyEvent {
  const LoadTodayActionsEvent();
}

class LoadUserActionsEvent extends DailyEvent {
  final int days;

  const LoadUserActionsEvent({this.days = 7});

  @override
  List<Object?> get props => [days];
}

class RecordActionEvent extends DailyEvent {
  final String actionType;
  final Map<String, dynamic>? metadata;

  const RecordActionEvent({
    required this.actionType,
    this.metadata,
  });

  @override
  List<Object?> get props => [actionType, metadata];
}

