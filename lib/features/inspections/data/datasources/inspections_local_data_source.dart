import '../../../../core/database/daos/inspections_dao.dart';
import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_sync_status.dart';

class InspectionsLocalDataSource {
  final InspectionsDao dao;

  const InspectionsLocalDataSource({
    required this.dao,
  });

  Future<void> save(
    Inspection inspection,
  ) {
    return dao.save(inspection);
  }

  Future<List<Inspection>> getAll() {
    return dao.getAll();
  }

  Future<List<Inspection>> getByStatus(
    InspectionSyncStatus status,
  ) {
    return dao.getByStatus(status);
  }

  Future<Inspection?> getByClientId(
    String clientId,
  ) {
    return dao.getByClientId(clientId);
  }

  Future<void> markAsSynced({
    required String clientId,
    required String serverId,
  }) {
    return dao.markAsSynced(
      clientId: clientId,
      serverId: serverId,
    );
  }

  Future<void> markAsFailed({
    required String clientId,
    required String error,
  }) {
    return dao.markAsFailed(
      clientId: clientId,
      error: error,
    );
  }
}