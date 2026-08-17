import '../../../../core/database/daos/work_orders_dao.dart';
import '../../domain/entities/work_order.dart';

class WorkOrdersLocalDataSource {
  final WorkOrdersDao dao;

  WorkOrdersLocalDataSource({
    required this.dao,
  });

  Future<void> saveWorkOrders(
    List<WorkOrder> workOrders,
  ) {
    return dao.saveAll(workOrders);
  }

  Future<List<WorkOrder>> getWorkOrders() {
    return dao.getAll();
  }
}