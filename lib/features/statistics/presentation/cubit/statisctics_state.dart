part of 'statisctics_cubit.dart';

@immutable
sealed class StatiscticsState {}

final class StatiscticsInitial extends StatiscticsState {
  StatiscticsInitial();
}

final class StatiscticsLoading extends StatiscticsState {
  StatiscticsLoading();
}

final class StatiscticsLoaded extends StatiscticsState {
  final int completed;

  StatiscticsLoaded({required this.completed});
}

final class StatiscticsError extends StatiscticsState {
  final String message;
  StatiscticsError(this.message);
}
