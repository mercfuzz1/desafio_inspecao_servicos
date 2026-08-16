import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/services/sync_service.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService syncService;

  SyncBloc({
    required this.syncService,
  }) : super(const SyncState()) {
    on<SyncRequested>(_onSyncRequested);
  }

  Future<void> _onSyncRequested(
    SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    if (state.status == SyncStatus.syncing) {
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
}