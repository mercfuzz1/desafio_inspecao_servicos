import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/work_orders_repository.dart';
import 'work_orders_event.dart';
import 'work_orders_state.dart';

class WorkOrdersBloc
    extends Bloc<WorkOrdersEvent, WorkOrdersState> {
  final WorkOrdersRepository repository;

  WorkOrdersBloc({
    required this.repository,
  }) : super(const WorkOrdersState()) {
    on<WorkOrdersRequested>(_onRequested);
    on<WorkOrdersRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onRequested(
    WorkOrdersRequested event,
    Emitter<WorkOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WorkOrdersStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final workOrders = await repository.getWorkOrders();

      if (workOrders.isEmpty) {
        emit(
          state.copyWith(
            status: WorkOrdersStatus.empty,
            workOrders: workOrders,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: WorkOrdersStatus.success,
          workOrders: workOrders,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkOrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    WorkOrdersRefreshRequested event,
    Emitter<WorkOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WorkOrdersStatus.refreshing,
        errorMessage: null,
      ),
    );

    try {
      final workOrders = await repository.getWorkOrders();

      if (workOrders.isEmpty) {
        emit(
          state.copyWith(
            status: WorkOrdersStatus.empty,
            workOrders: workOrders,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: WorkOrdersStatus.success,
          workOrders: workOrders,
        ),
      );
    } catch (e) {
      // mantém os dados anteriores caso o refresh falhe
      emit(
        state.copyWith(
          status: state.workOrders.isEmpty
              ? WorkOrdersStatus.failure
              : WorkOrdersStatus.success,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}