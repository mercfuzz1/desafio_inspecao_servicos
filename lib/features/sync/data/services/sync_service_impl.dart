import '../../../inspections/domain/entities/inspection.dart';
import '../../../inspections/domain/entities/inspection_sync_status.dart';
import '../../../inspections/domain/repositories/inspections_repository.dart';
import '../../domain/services/sync_service.dart';
import 'package:dio/dio.dart';

class SyncServiceImpl implements SyncService {
  final InspectionsRepository inspectionsRepository;

  const SyncServiceImpl({required this.inspectionsRepository});

  String _getReadableError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return 'A conexão demorou muito para responder.';

        case DioExceptionType.connectionError:
          return 'Não foi possível conectar ao servidor.';

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;

          if (statusCode != null && statusCode >= 500) {
            return 'O servidor está indisponível no momento.';
          }

          return 'O servidor recusou a inspeção.';

        case DioExceptionType.cancel:
          return 'A sincronização foi cancelada.';

        case DioExceptionType.badCertificate:
          return 'Não foi possível validar a conexão com o servidor.';

        case DioExceptionType.unknown:
          return 'Ocorreu um erro durante a sincronização.';
      }
    }

    return 'Ocorreu um erro durante a sincronização.';
  }

  @override
  Future<void> sync() async {
    final inspections = await inspectionsRepository.getByStatus(
      InspectionSyncStatus.pending,
    );

    await _processInspections(inspections);
  }

  @override
  Future<void> retryFailed() async {
    final inspections = await inspectionsRepository.getByStatus(
      InspectionSyncStatus.failed,
    );

    await _processInspections(inspections);
  }

  Future<void> _processInspections(List<Inspection> inspections) async {
    for (final inspection in inspections) {
      try {
        final serverId = await inspectionsRepository.send(inspection);

        await inspectionsRepository.markAsSynced(
          clientId: inspection.clientId,
          serverId: serverId,
        );
      } catch (error) {
        await inspectionsRepository.markAsFailed(
          clientId: inspection.clientId,
          error: _getReadableError(error),
        );
      }
    }
  }
}
