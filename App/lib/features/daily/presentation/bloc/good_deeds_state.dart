import 'package:equatable/equatable.dart';
import 'package:sapit/features/daily/domain/entities/azkar_group.dart';
import 'package:sapit/features/daily/domain/entities/azkar_completion.dart';
import 'package:sapit/features/daily/domain/entities/fasting_completion.dart';

abstract class GoodDeedsState extends Equatable {
  const GoodDeedsState();

  @override
  List<Object?> get props => [];
}

class GoodDeedsInitial extends GoodDeedsState {}

class GoodDeedsLoading extends GoodDeedsState {}

// Azkar Groups States
class AzkarGroupsLoaded extends GoodDeedsState {
  final List<AzkarGroup> groups;
  final List<AzkarCompletion> completions;

  const AzkarGroupsLoaded({
    required this.groups,
    this.completions = const [],
  });

  @override
  List<Object?> get props => [groups, completions];
}

class AzkarGroupLoaded extends GoodDeedsState {
  final AzkarGroup group;
  final List<AzkarCompletion> completions;

  const AzkarGroupLoaded({
    required this.group,
    this.completions = const [],
  });

  @override
  List<Object?> get props => [group, completions];
}

// Azkar Completion States
class AzkarCompleted extends GoodDeedsState {
  final int xpEarned;
  final int coinsEarned;
  final String message;

  const AzkarCompleted({
    required this.xpEarned,
    required this.coinsEarned,
    this.message = 'Azkar completed successfully!',
  });

  @override
  List<Object?> get props => [xpEarned, coinsEarned, message];
}

class AzkarCompletionsLoaded extends GoodDeedsState {
  final List<AzkarCompletion> completions;

  const AzkarCompletionsLoaded(this.completions);

  @override
  List<Object?> get props => [completions];
}

// Fasting States
class FastingStatusLoaded extends GoodDeedsState {
  final FastingStatus status;

  const FastingStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

class FastingCompleted extends GoodDeedsState {
  final int xpEarned;
  final int coinsEarned;
  final String message;

  const FastingCompleted({
    required this.xpEarned,
    required this.coinsEarned,
    this.message = 'Fasting recorded successfully!',
  });

  @override
  List<Object?> get props => [xpEarned, coinsEarned, message];
}

// Error State
class GoodDeedsError extends GoodDeedsState {
  final String message;

  const GoodDeedsError(this.message);

  @override
  List<Object?> get props => [message];
}

