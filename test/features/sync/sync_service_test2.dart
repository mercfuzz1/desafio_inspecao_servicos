import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/inspections/domain/entities/inspection.dart';
import 'package:flutter_application_1/features/inspections/domain/entities/inspection_sync_status.dart';
import 'package:flutter_application_1/features/inspections/domain/repositories/inspections_repository.dart';
import 'package:flutter_application_1/features/sync/data/services/sync_service_impl.dart';

class FakeInspectionsRepository
    implements InspectionsRepository {
  final List<Inspection> pendingInspections;
  final List<Inspection> failedInspections;

  final List<Inspection> sentInspections = [];

  final List<String> syncedClientIds = [];
  final List<String> failedClientIds = [];

  final Map<String, String> serverIds = {};

  final Set<String> clientIdsToFail;

  FakeInspectionsRepository({
    this.pendingInspections = const [],
    this.failedInspections = const [],
    this.clientIdsToFail = const {},
  });

  @override
  Future<List<Inspection>> getByStatus(
    InspectionSyncStatus status,
  ) async {
    switch (status) {
      case InspectionSyncStatus.pending:
        return pendingInspections;

      case InspectionSyncStatus.failed:
        return failedInspections;

      default:
        return [];
    }
  }

  @override
  Future<String> send(
    Inspection inspection,
  ) async {
    sentInspections.add(inspection);

    if (clientIdsToFail.contains(
      inspection.clientId,
    )) {
      throw Exception(
        'Erro de conexão',
      );
    }

    const serverId = 'insp_server_001';

    serverIds[inspection.clientId] =
        serverId;

    return serverId;
  }

  @override
  Future<void> markAsSynced({
    required String clientId,
    required String serverId,
  }) async {
    syncedClientIds.add(clientId);
  }

  @override
  Future<void> markAsFailed({
    required String clientId,
    required String error,
  }) async {
    failedClientIds.add(clientId);
  }

  @override
  Future<void> save(
    Inspection inspection,
  ) async {}

  @override
  Future<List<Inspection>> getAll() async {
    return [
      ...pendingInspections,
      ...failedInspections,
    ];
  }

  @override
  Future<Inspection?> getByClientId(
    String clientId,
  ) async {
    for (final inspection in [
      ...pendingInspections,
      ...failedInspections,
    ]) {
      if (inspection.clientId ==
          clientId) {
        return inspection;
      }
    }

    return null;
  }
}

Inspection createInspection({
  required String clientId,
  InspectionSyncStatus status =
      InspectionSyncStatus.pending,
}) {
  return Inspection(
    clientId: clientId,
    serverId: null,
    workOrderId: 'wo_1001',
    observation:
        'Inspeção realizada no poste.',
    condition: 'bom',
    photoPath: '/tmp/photo.jpg',
    latitude: -7.1195,
    longitude: -34.8450,
    capturedAt:
        DateTime(2026, 8, 16, 10),
    syncStatus: status,
    syncError: null,
    createdAt:
        DateTime(2026, 8, 16, 10),
    updatedAt:
        DateTime(2026, 8, 16, 10),
  );
}

void main() {
  group(
    'SyncServiceImpl',
    () {
      test(
        'deve sincronizar uma inspeção pending com sucesso',
        () async {
          final inspection =
              createInspection(
            clientId: 'client_001',
          );

          final repository =
              FakeInspectionsRepository(
            pendingInspections: [
              inspection,
            ],
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.sync();

          expect(
            repository.sentInspections,
            hasLength(1),
          );

          expect(
            repository
                .sentInspections
                .first
                .clientId,
            'client_001',
          );

          expect(
            repository.syncedClientIds,
            contains('client_001'),
          );

          expect(
            repository.failedClientIds,
            isEmpty,
          );
        },
      );

      test(
        'deve marcar a inspeção como failed quando o envio falhar',
        () async {
          final inspection =
              createInspection(
            clientId: 'client_001',
          );

          final repository =
              FakeInspectionsRepository(
            pendingInspections: [
              inspection,
            ],
            clientIdsToFail: {
              'client_001',
            },
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.sync();

          expect(
            repository.sentInspections,
            hasLength(1),
          );

          expect(
            repository.syncedClientIds,
            isEmpty,
          );

          expect(
            repository.failedClientIds,
            contains('client_001'),
          );
        },
      );

      test(
        'deve reenviar inspeções failed',
        () async {
          final inspection =
              createInspection(
            clientId: 'client_001',
            status:
                InspectionSyncStatus.failed,
          );

          final repository =
              FakeInspectionsRepository(
            failedInspections: [
              inspection,
            ],
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.retryFailed();

          expect(
            repository.sentInspections,
            hasLength(1),
          );

          expect(
            repository
                .sentInspections
                .first
                .clientId,
            'client_001',
          );

          expect(
            repository.syncedClientIds,
            contains('client_001'),
          );
        },
      );

      test(
        'deve reutilizar o mesmo clientId no retry',
        () async {
          final inspection =
              createInspection(
            clientId:
                'client_retry_001',
            status:
                InspectionSyncStatus.failed,
          );

          final repository =
              FakeInspectionsRepository(
            failedInspections: [
              inspection,
            ],
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.retryFailed();

          expect(
            repository.sentInspections,
            hasLength(1),
          );

          expect(
            repository
                .sentInspections
                .first
                .clientId,
            'client_retry_001',
          );

          expect(
            repository.syncedClientIds,
            contains(
              'client_retry_001',
            ),
          );
        },
      );

      test(
        'não deve processar inspeções draft',
        () async {
          final repository =
              FakeInspectionsRepository(
            pendingInspections: [],
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.sync();

          expect(
            repository.sentInspections,
            isEmpty,
          );

          expect(
            repository.syncedClientIds,
            isEmpty,
          );

          expect(
            repository.failedClientIds,
            isEmpty,
          );
        },
      );

      test(
        'deve continuar processando a fila mesmo quando uma inspeção falhar',
        () async {
          final inspection1 =
              createInspection(
            clientId: 'client_001',
          );

          final inspection2 =
              createInspection(
            clientId: 'client_002',
          );

          final inspection3 =
              createInspection(
            clientId: 'client_003',
          );

          final inspection4 =
              createInspection(
            clientId: 'client_004',
          );

          final repository =
              FakeInspectionsRepository(
            pendingInspections: [
              inspection1,
              inspection2,
              inspection3,
              inspection4,
            ],
            clientIdsToFail: {
              'client_003',
            },
          );

          final service =
              SyncServiceImpl(
            inspectionsRepository:
                repository,
          );

          await service.sync();

          expect(
            repository.sentInspections,
            hasLength(4),
          );

          expect(
            repository.syncedClientIds,
            containsAll([
              'client_001',
              'client_002',
              'client_004',
            ]),
          );

          expect(
            repository.failedClientIds,
            contains(
              'client_003',
            ),
          );

          expect(
            repository.syncedClientIds,
            isNot(
              contains('client_003'),
            ),
          );
        },
      );
    },
  );
}