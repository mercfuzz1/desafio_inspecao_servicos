// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_orders_dao.dart';

// ignore_for_file: type=lint
mixin _$WorkOrdersDaoMixin on DatabaseAccessor<AppDatabase> {
  $WorkOrdersTableTable get workOrdersTable => attachedDatabase.workOrdersTable;
  WorkOrdersDaoManager get managers => WorkOrdersDaoManager(this);
}

class WorkOrdersDaoManager {
  final _$WorkOrdersDaoMixin _db;
  WorkOrdersDaoManager(this._db);
  $$WorkOrdersTableTableTableManager get workOrdersTable =>
      $$WorkOrdersTableTableTableManager(
        _db.attachedDatabase,
        _db.workOrdersTable,
      );
}
