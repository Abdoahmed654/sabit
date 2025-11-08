import 'package:equatable/equatable.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';

abstract class GoodDeedsEvent extends Equatable {
  const GoodDeedsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAzkarGroupsEvent extends GoodDeedsEvent {
  final AzkarCategory? category;

  const LoadAzkarGroupsEvent({this.category});

  @override
  List<Object?> get props => [category];
}

class LoadAzkarGroupEvent extends GoodDeedsEvent {
  final String groupId;

  const LoadAzkarGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CompleteAzkarEvent extends GoodDeedsEvent {
  final String azkarId;

  const CompleteAzkarEvent(this.azkarId);

  @override
  List<Object?> get props => [azkarId];
}

class LoadAzkarCompletionsEvent extends GoodDeedsEvent {
  final String? groupId;

  const LoadAzkarCompletionsEvent({this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class CompleteFastingEvent extends GoodDeedsEvent {
  final String fastingType;

  const CompleteFastingEvent(this.fastingType);

  @override
  List<Object?> get props => [fastingType];
}

class LoadFastingStatusEvent extends GoodDeedsEvent {
  const LoadFastingStatusEvent();
}

