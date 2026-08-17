import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_sync_status.dart';
import '../../domain/repositories/inspections_repository.dart';

enum InspectionsHistoryStatus {
  initial,
  loading,
  success,
  failure,
}

class InspectionsHistoryState {
  final InspectionsHistoryStatus status;
  final List<Inspection> inspections;
  final String? errorMessage;
  final InspectionSyncStatus? filter;

  const InspectionsHistoryState({
    this.status = InspectionsHistoryStatus.initial,
    this.inspections = const [],
    this.errorMessage,
    this.filter,
  });

  InspectionsHistoryState copyWith({
    InspectionsHistoryStatus? status,
    List<Inspection>? inspections,
    String? errorMessage,
    InspectionSyncStatus? filter,
    bool clearFilter = false,
  }) {
    return InspectionsHistoryState(
      status: status ?? this.status,
      inspections: inspections ?? this.inspections,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: clearFilter ? null : filter ?? this.filter,
    );
  }
}

class InspectionsHistoryBloc
    extends Cubit<InspectionsHistoryState> {
  final InspectionsRepository repository;

  InspectionsHistoryBloc({
    required this.repository,
  }) : super(
          const InspectionsHistoryState(),
        );

  Future<void> load() async {
    emit(
      state.copyWith(
        status: InspectionsHistoryStatus.loading,
      ),
    );

    try {
      final inspections = await _loadInspections();

      emit(
        state.copyWith(
          status: InspectionsHistoryStatus.success,
          inspections: inspections,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InspectionsHistoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final inspections = await _loadInspections();

      emit(
        state.copyWith(
          status: InspectionsHistoryStatus.success,
          inspections: inspections,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InspectionsHistoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> filterBy(
    InspectionSyncStatus? status,
  ) async {
    emit(
      state.copyWith(
        filter: status,
        clearFilter: status == null,
      ),
    );

    await refresh();
  }

  Future<List<Inspection>> _loadInspections() {
    final filter = state.filter;

    if (filter == null) {
      return repository.getAll();
    }

    return repository.getByStatus(filter);
  }
}