import '../entities/inspection.dart';
import '../entities/inspection_sync_status.dart';

abstract interface class InspectionsRepository {
  Future<void> save(
    Inspection inspection,
  );

  Future<List<Inspection>> getAll();

  Future<List<Inspection>> getByStatus(
    InspectionSyncStatus status,
  );

  Future<Inspection?> getByClientId(
    String clientId,
  );

  Future<void> markAsSynced({
    required String clientId,
    required String serverId,
  });

  Future<void> markAsFailed({
    required String clientId,
    required String error,
  });

  Future<String> send(
    Inspection inspection,
  );
}