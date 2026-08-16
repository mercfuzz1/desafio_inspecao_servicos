import '../../../inspections/domain/entities/inspection.dart';
import '../../../inspections/domain/entities/inspection_sync_status.dart';
import '../../../inspections/domain/repositories/inspections_repository.dart';
import '../../domain/services/sync_service.dart';

class SyncServiceImpl implements SyncService {
  final InspectionsRepository inspectionsRepository;

  const SyncServiceImpl({
    required this.inspectionsRepository,
  });

  @override
  Future<void> sync() async {
    final inspections =
        await inspectionsRepository.getByStatus(
      InspectionSyncStatus.pending,
    );

    await _processInspections(
      inspections,
    );
  }

  @override
  Future<void> retryFailed() async {
    final inspections =
        await inspectionsRepository.getByStatus(
      InspectionSyncStatus.failed,
    );

    await _processInspections(
      inspections,
    );
  }

  Future<void> _processInspections(
    List<Inspection> inspections,
  ) async {
    for (final inspection in inspections) {
      try {
        final serverId =
            await inspectionsRepository.send(
          inspection,
        );

        await inspectionsRepository.markAsSynced(
          clientId: inspection.clientId,
          serverId: serverId,
        );
      } catch (error) {
        await inspectionsRepository.markAsFailed(
          clientId: inspection.clientId,
          error: error.toString(),
        );
      }
    }
  }
}