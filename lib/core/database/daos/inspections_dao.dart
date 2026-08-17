import 'package:drift/drift.dart';

import '../../../features/inspections/domain/entities/inspection.dart';
import '../../../features/inspections/domain/entities/inspection_sync_status.dart';
import '../app_database.dart';
import '../tables/inspections.dart';

part 'inspections_dao.g.dart';

@DriftAccessor(tables: [InspectionTable])
class InspectionsDao extends DatabaseAccessor<AppDatabase>
    with _$InspectionsDaoMixin {
  InspectionsDao(super.db);

  Future<void> save(Inspection inspection) async {
    await into(inspectionTable).insertOnConflictUpdate(
      InspectionTableCompanion.insert(
        clientId: inspection.clientId,
        serverId: Value(inspection.serverId),
        workOrderId: inspection.workOrderId,
        observation: inspection.observation,
        condition: Value(inspection.condition),
        photoPath: inspection.photoPath,
        latitude: inspection.latitude,
        longitude: inspection.longitude,
        capturedAt: inspection.capturedAt,
        syncStatus: inspection.syncStatus.name,
        syncError: Value(inspection.syncError),
        createdAt: inspection.createdAt,
        updatedAt: inspection.updatedAt,
      ),
    );
  }

  Future<List<Inspection>> getAll() async {
    final rows = await select(inspectionTable).get();

    return rows.map(_toDomain).toList();
  }

  Future<Inspection?> getByClientId(String clientId) async {
    final row = await (select(
      inspectionTable,
    )..where((table) => table.clientId.equals(clientId))).getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toDomain(row);
  }

  Future<List<Inspection>> getByStatus(InspectionSyncStatus status) async {
    final rows = await (select(
      inspectionTable,
    )..where((table) => table.syncStatus.equals(status.name))).get();

    return rows.map(_toDomain).toList();
  }

  Inspection _toDomain(InspectionTableData data) {
    return Inspection(
      clientId: data.clientId,
      serverId: data.serverId,
      workOrderId: data.workOrderId,
      observation: data.observation,
      condition: data.condition,
      photoPath: data.photoPath,
      latitude: data.latitude,
      longitude: data.longitude,
      capturedAt: data.capturedAt,
      syncStatus: InspectionSyncStatus.values.firstWhere(
        (status) => status.name == data.syncStatus,
      ),
      syncError: data.syncError,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  Future<void> markAsSynced({
    required String clientId,
    required String serverId,
  }) async {
    await (update(
      inspectionTable,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionTableCompanion(
        serverId: Value(serverId),
        syncStatus: const Value('synced'),
        syncError: Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markAsFailed({
    required String clientId,
    required String error,
  }) async {
    await (update(
      inspectionTable,
    )..where((table) => table.clientId.equals(clientId))).write(
      InspectionTableCompanion(
        syncStatus: const Value('failed'),
        syncError: Value(error),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Inspection>> getPending() {
    return getByStatus(InspectionSyncStatus.pending);
  }

  Future<List<Inspection>> getFailed() {
    return getByStatus(InspectionSyncStatus.failed);
  }
}
