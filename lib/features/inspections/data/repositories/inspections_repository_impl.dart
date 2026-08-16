import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_sync_status.dart';
import '../../domain/repositories/inspections_repository.dart';
import '../datasources/inspections_local_data_source.dart';

class InspectionsRepositoryImpl
    implements InspectionsRepository {
  final InspectionsLocalDataSource localDataSource;

  const InspectionsRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> save(
    Inspection inspection,
  ) {
    return localDataSource.save(inspection);
  }

  @override
  Future<List<Inspection>> getAll() {
    return localDataSource.getAll();
  }

  @override
  Future<List<Inspection>> getByStatus(
    InspectionSyncStatus status,
  ) {
    return localDataSource.getByStatus(status);
  }

  @override
  Future<Inspection?> getByClientId(
    String clientId,
  ) {
    return localDataSource.getByClientId(clientId);
  }

  @override
  Future<void> markAsSynced({
    required String clientId,
    required String serverId,
  }) {
    return localDataSource.markAsSynced(
      clientId: clientId,
      serverId: serverId,
    );
  }

  @override
  Future<void> markAsFailed({
    required String clientId,
    required String error,
  }) {
    return localDataSource.markAsFailed(
      clientId: clientId,
      error: error,
    );
  }
}