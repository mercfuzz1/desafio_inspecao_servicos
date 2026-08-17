import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/inspections_dao.dart';
import 'daos/work_orders_dao.dart';
import 'tables/inspections.dart';
import 'tables/work_orders.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    InspectionTable,
    WorkOrdersTable,
  ],
  daos: [
    InspectionsDao,
    WorkOrdersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(workOrdersTable);
        }
      },
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'field_inspection',
  );
}