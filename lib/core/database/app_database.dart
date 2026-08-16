import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_application_1/core/database/daos/inspections_dao.dart';

import 'tables/inspections.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    InspectionTable,
  ],
  daos: [
    InspectionsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'field_inspection',
  );
}