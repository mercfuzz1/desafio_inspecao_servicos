import 'package:equatable/equatable.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

final class SyncRequested extends SyncEvent {
  const SyncRequested();
}

final class SyncRetryFailedRequested extends SyncEvent {
  const SyncRetryFailedRequested();
}