import '../entities/work_order.dart';

abstract interface class WorkOrdersRepository {
  Future<List<WorkOrder>> getWorkOrders();
}