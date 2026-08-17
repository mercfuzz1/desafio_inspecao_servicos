import 'package:drift/drift.dart';

import '../../../features/work_orders/domain/entities/work_order.dart';
import '../app_database.dart';
import '../tables/work_orders.dart';

part 'work_orders_dao.g.dart';

@DriftAccessor(tables: [WorkOrdersTable])
class WorkOrdersDao extends DatabaseAccessor<AppDatabase>
    with _$WorkOrdersDaoMixin {
  WorkOrdersDao(super.db);

  Future<void> saveAll(List<WorkOrder> workOrders) async {
    await transaction(() async {
      await delete(workOrdersTable).go();

      await batch((batch) {
        batch.insertAll(
          workOrdersTable,
          workOrders
              .map(
                (workOrder) => WorkOrdersTableCompanion.insert(
                  id: workOrder.id,
                  code: workOrder.code,
                  title: workOrder.title,
                  description: workOrder.description,
                  address: workOrder.address,
                  priority: workOrder.priority,
                  status: workOrder.status,
                  latitude: workOrder.latitude,
                  longitude: workOrder.longitude,
                  scheduledAt: workOrder.scheduledAt,
                  updatedAt: workOrder.updatedAt,
                ),
              )
              .toList(),
        );
      });
    });
  }

  Future<List<WorkOrder>> getAll() async {
    final rows = await select(workOrdersTable).get();

    return rows.map(_toDomain).toList();
  }

  Future<WorkOrder?> getById(String id) async {
    final row = await (select(
      workOrdersTable,
    )..where((table) => table.id.equals(id))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  WorkOrder _toDomain(WorkOrdersTableData data) {
    return WorkOrder(
      id: data.id,
      code: data.code,
      title: data.title,
      description: data.description,
      address: data.address,
      priority: data.priority,
      status: data.status,
      latitude: data.latitude,
      longitude: data.longitude,
      scheduledAt: data.scheduledAt,
      updatedAt: data.updatedAt,
    );
  }
}
