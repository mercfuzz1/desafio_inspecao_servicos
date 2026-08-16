import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/connectivity/connectivity_service.dart';
import '../../domain/services/sync_service.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService syncService;
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;

  SyncBloc({
    required this.syncService,
    required this.connectivityService,
  }) : super(const SyncState()) {
    on<SyncRequested>(_onSyncRequested);

    _connectivitySubscription =
        connectivityService.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected) {
          add(
            const SyncRequested(),
          );
        }
      },
    );
  }

  Future<void> _onSyncRequested(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    if (state.status == SyncStatus.syncing) {
      return;
    }

    final isConnected =
        await connectivityService.isConnected;

    if (!isConnected) {
      return;
    }

    emit(
      state.copyWith(
        status: SyncStatus.syncing,
        clearErrorMessage: true,
      ),
    );

    try {
      await syncService.sync();

      emit(
        state.copyWith(
          status: SyncStatus.success,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SyncStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();

    return super.close();
  }
}