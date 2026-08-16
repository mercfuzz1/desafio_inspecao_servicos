// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspections_dao.dart';

// ignore_for_file: type=lint
mixin _$InspectionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $InspectionTableTable get inspectionTable => attachedDatabase.inspectionTable;
  InspectionsDaoManager get managers => InspectionsDaoManager(this);
}

class InspectionsDaoManager {
  final _$InspectionsDaoMixin _db;
  InspectionsDaoManager(this._db);
  $$InspectionTableTableTableManager get inspectionTable =>
      $$InspectionTableTableTableManager(
        _db.attachedDatabase,
        _db.inspectionTable,
      );
}
