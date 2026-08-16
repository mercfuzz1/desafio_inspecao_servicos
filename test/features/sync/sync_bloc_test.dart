import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/connectivity/connectivity_service.dart';
import 'package:flutter_application_1/features/sync/domain/services/sync_service.dart';
import 'package:flutter_application_1/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:flutter_application_1/features/sync/presentation/bloc/sync_event.dart';
import 'package:flutter_application_1/features/sync/presentation/bloc/sync_state.dart';

class FakeSyncService implements SyncService {
  int syncCalls = 0;
  int retryFailedCalls = 0;

  bool shouldFailSync = false;
  bool shouldFailRetry = false;

  @override
  Future<void> sync() async {
    syncCalls++;

    if (shouldFailSync) {
      throw Exception('Erro ao sincronizar');
    }
  }

  @override
  Future<void> retryFailed() async {
    retryFailedCalls++;

    if (shouldFailRetry) {
      throw Exception('Erro ao tentar novamente');
    }
  }
}

class FakeConnectivityService implements ConnectivityService {
  bool connected;

  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  FakeConnectivityService({
    this.connected = true,
  });

  @override
  Future<bool> get isConnected async {
    return connected;
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _controller.stream;
  }

  void emitConnectivity(bool value) {
    connected = value;
    _controller.add(value);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  group('SyncBloc', () {
    late FakeSyncService syncService;
    late FakeConnectivityService connectivityService;
    late SyncBloc syncBloc;

    setUp(() {
      syncService = FakeSyncService();

      connectivityService = FakeConnectivityService(
        connected: true,
      );

      syncBloc = SyncBloc(
        syncService: syncService,
        connectivityService: connectivityService,
      );
    });

    tearDown(() async {
      await syncBloc.close();
      await connectivityService.dispose();
    });

    test(
      'deve iniciar com status initial',
      () {
        expect(
          syncBloc.state.status,
          SyncStatus.initial,
        );

        expect(
          syncBloc.state.errorMessage,
          isNull,
        );
      },
    );

    test(
      'deve sincronizar quando receber SyncRequested',
      () async {
        syncBloc.add(
          const SyncRequested(),
        );

        await expectLater(
          syncBloc.stream,
          emitsInOrder([
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.syncing,
            ),
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.success,
            ),
          ]),
        );

        expect(
          syncService.syncCalls,
          1,
        );
      },
    );

    test(
      'não deve sincronizar quando estiver sem conexão',
      () async {
        connectivityService.connected = false;

        syncBloc.add(
          const SyncRequested(),
        );

        await Future<void>.delayed(
          const Duration(milliseconds: 100),
        );

        expect(
          syncService.syncCalls,
          0,
        );

        expect(
          syncBloc.state.status,
          SyncStatus.initial,
        );
      },
    );

    test(
      'deve entrar em failure quando a sincronização falhar',
      () async {
        syncService.shouldFailSync = true;

        syncBloc.add(
          const SyncRequested(),
        );

        await expectLater(
          syncBloc.stream,
          emitsInOrder([
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.syncing,
            ),
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.failure &&
                  state.errorMessage != null,
            ),
          ]),
        );

        expect(
          syncService.syncCalls,
          1,
        );

        expect(
          syncBloc.state.errorMessage,
          contains(
            'Erro ao sincronizar',
          ),
        );
      },
    );

    test(
      'deve tentar novamente as inspeções failed',
      () async {
        syncBloc.add(
          const SyncRetryFailedRequested(),
        );

        await expectLater(
          syncBloc.stream,
          emitsInOrder([
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.syncing,
            ),
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.success,
            ),
          ]),
        );

        expect(
          syncService.retryFailedCalls,
          1,
        );
      },
    );

    test(
      'deve entrar em failure quando retryFailed falhar',
      () async {
        syncService.shouldFailRetry = true;

        syncBloc.add(
          const SyncRetryFailedRequested(),
        );

        await expectLater(
          syncBloc.stream,
          emitsInOrder([
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.syncing,
            ),
            predicate<SyncState>(
              (state) =>
                  state.status ==
                      SyncStatus.failure &&
                  state.errorMessage != null,
            ),
          ]),
        );

        expect(
          syncService.retryFailedCalls,
          1,
        );

        expect(
          syncBloc.state.errorMessage,
          contains(
            'Erro ao tentar novamente',
          ),
        );
      },
    );

    test(
      'deve iniciar sincronização automaticamente quando recuperar conexão',
      () async {
        connectivityService.connected = false;

        syncBloc.add(
          const SyncRequested(),
        );

        await Future<void>.delayed(
          const Duration(milliseconds: 100),
        );

        expect(
          syncService.syncCalls,
          0,
        );

        connectivityService.emitConnectivity(
          true,
        );

        await expectLater(
          syncBloc.stream,
          emitsInOrder([
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.syncing,
            ),
            predicate<SyncState>(
              (state) =>
                  state.status ==
                  SyncStatus.success,
            ),
          ]),
        );

        expect(
          syncService.syncCalls,
          1,
        );
      },
    );
  });
}