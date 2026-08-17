import 'package:drift/drift.dart';

class InspectionTable extends Table {
  TextColumn get clientId => text()();

  TextColumn get serverId => text().nullable()();

  TextColumn get workOrderId => text()();

  TextColumn get observation => text()();

  TextColumn get condition => text().nullable()();

  TextColumn get photoPath => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  DateTimeColumn get capturedAt => dateTime()();

  TextColumn get syncStatus => text()();

  TextColumn get syncError => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {clientId};
}