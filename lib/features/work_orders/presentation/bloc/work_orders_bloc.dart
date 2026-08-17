import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/work_orders_repository.dart';
import 'work_orders_event.dart';
import 'work_orders_state.dart';

class WorkOrdersBloc extends Bloc<WorkOrdersEvent, WorkOrdersState> {
  final WorkOrdersRepository repository;

  WorkOrdersBloc({required this.repository}) : super(const WorkOrdersState()) {
    on<WorkOrdersRequested>(_onWorkOrdersRequested);
    on<WorkOrdersRefreshRequested>(_onWorkOrdersRefreshRequested);
  }

  Future<void> _onWorkOrdersRequested(
    WorkOrdersRequested event,
    Emitter<WorkOrdersState> emit,
  ) async {
    emit(
      state.copyWith(status: WorkOrdersStatus.loading, clearErrorMessage: true),
    );

    try {
      final workOrders = await repository.getWorkOrders();

      if (workOrders.isEmpty) {
        emit(
          state.copyWith(
            status: WorkOrdersStatus.empty,
            workOrders: workOrders,
            clearErrorMessage: true,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: WorkOrdersStatus.success,
          workOrders: workOrders,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: WorkOrdersStatus.failure,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onWorkOrdersRefreshRequested(
    WorkOrdersRefreshRequested event,
    Emitter<WorkOrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WorkOrdersStatus.refreshing,
        clearErrorMessage: true,
      ),
    );

    try {
      final workOrders = await repository.getWorkOrders();

      if (workOrders.isEmpty) {
        emit(
          state.copyWith(
            status: WorkOrdersStatus.empty,
            workOrders: workOrders,
            clearErrorMessage: true,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          status: WorkOrdersStatus.success,
          workOrders: workOrders,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: WorkOrdersStatus.success,
          errorMessage: _getErrorMessage(error),
        ),
      );
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionError:
          return 'Sem conexão com a internet.';

        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.transformTimeout:
          return 'A conexão demorou muito para responder.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;

          if (statusCode == 401) {
            return 'Sua sessão expirou. Faça login novamente.';
          }

          if (statusCode != null && statusCode >= 500) {
            return 'O servidor está indisponível no momento.';
          }

          final message = error.response?.data?['message'];

          if (message is String && message.isNotEmpty) {
            return message;
          }

          return 'Não foi possível atualizar as ordens de serviço.';

        case DioExceptionType.cancel:
          return 'A atualização foi cancelada.';

        case DioExceptionType.badCertificate:
          return 'Não foi possível estabelecer uma conexão segura.';

        case DioExceptionType.unknown:
          return 'Não foi possível conectar ao servidor.';
      }
    }

    return 'Ocorreu um erro ao carregar as ordens de serviço.';
  }
}
