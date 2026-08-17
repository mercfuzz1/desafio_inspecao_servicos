import 'package:equatable/equatable.dart';

import '../../domain/entities/work_order.dart';

enum WorkOrdersStatus {
  initial,
  loading,
  refreshing,
  success,
  empty,
  failure,
}

class WorkOrdersState extends Equatable {
  final WorkOrdersStatus status;
  final List<WorkOrder> workOrders;
  final String? errorMessage;

  const WorkOrdersState({
    this.status = WorkOrdersStatus.initial,
    this.workOrders = const [],
    this.errorMessage,
  });

  WorkOrdersState copyWith({
    WorkOrdersStatus? status,
    List<WorkOrder>? workOrders,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WorkOrdersState(
      status: status ?? this.status,
      workOrders: workOrders ?? this.workOrders,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        workOrders,
        errorMessage,
      ];
}