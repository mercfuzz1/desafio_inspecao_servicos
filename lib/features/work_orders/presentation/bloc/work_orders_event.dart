import 'package:equatable/equatable.dart';

abstract class WorkOrdersEvent extends Equatable {
  const WorkOrdersEvent();

  @override
  List<Object?> get props => [];
}

class WorkOrdersRequested extends WorkOrdersEvent {
  const WorkOrdersRequested();
}

class WorkOrdersRefreshRequested extends WorkOrdersEvent {
  const WorkOrdersRefreshRequested();
}