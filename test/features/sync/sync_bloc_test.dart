import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
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
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  FakeConnectivityService({this.connected = true});
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
    setUp(() {
      syncService = FakeSyncService();
      connectivityService = FakeConnectivityService(connected: true);
    });
    tearDown(() async {
      await connectivityService.dispose();
    });
    test('deve iniciar com status initial', () {
      final bloc = SyncBloc(
        syncService: syncService,
        connectivityService: connectivityService,
      );
      expect(bloc.state.status, SyncStatus.initial);
      expect(bloc.state.errorMessage, isNull);
      bloc.close();
    });
    blocTest<SyncBloc, SyncState>(
      'deve sincronizar quando receber SyncRequested',
      build: () => SyncBloc(
        syncService: syncService,
        connectivityService: connectivityService,
      ),
      act: (bloc) {
        bloc.add(const SyncRequested());
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.initial && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.syncing && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.success && state.errorMessage == null,
        ),
      ],
      verify: (_) {
        expect(syncService.syncCalls, 1);
      },
    );
    blocTest<SyncBloc, SyncState>(
      'não deve sincronizar quando estiver sem conexão',
      build: () {
        connectivityService.connected = false;
        return SyncBloc(
          syncService: syncService,
          connectivityService: connectivityService,
        );
      },
      act: (bloc) {
        bloc.add(const SyncRequested());
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.initial && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.failure &&
              state.errorMessage == 'Sem conexão com a internet.',
        ),
      ],
      verify: (_) {
        expect(syncService.syncCalls, 0);
      },
    );
    blocTest<SyncBloc, SyncState>(
      'deve entrar em failure quando a sincronização falhar',
      build: () {
        syncService.shouldFailSync = true;
        return SyncBloc(
          syncService: syncService,
          connectivityService: connectivityService,
        );
      },
      act: (bloc) {
        bloc.add(const SyncRequested());
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.initial && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.syncing && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.contains('Erro ao sincronizar'),
        ),
      ],
      verify: (_) {
        expect(syncService.syncCalls, 1);
      },
    );
    blocTest<SyncBloc, SyncState>(
      'deve tentar novamente as inspeções failed',
      build: () => SyncBloc(
        syncService: syncService,
        connectivityService: connectivityService,
      ),
      act: (bloc) {
        bloc.add(const SyncRetryFailedRequested());
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.syncing && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.success && state.errorMessage == null,
        ),
      ],
      verify: (_) {
        expect(syncService.retryFailedCalls, 1);
      },
    );
    blocTest<SyncBloc, SyncState>(
      'deve entrar em failure quando retryFailed falhar',
      build: () {
        syncService.shouldFailRetry = true;
        return SyncBloc(
          syncService: syncService,
          connectivityService: connectivityService,
        );
      },
      act: (bloc) {
        bloc.add(const SyncRetryFailedRequested());
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.syncing && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.failure &&
              state.errorMessage != null &&
              state.errorMessage!.contains('Erro ao tentar novamente'),
        ),
      ],
      verify: (_) {
        expect(syncService.retryFailedCalls, 1);
      },
    );
    blocTest<SyncBloc, SyncState>(
      'deve iniciar sincronização automaticamente quando recuperar conexão',
      build: () {
        connectivityService.connected = false;
        return SyncBloc(
          syncService: syncService,
          connectivityService: connectivityService,
        );
      },
      act: (bloc) async {
        connectivityService.emitConnectivity(true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.initial && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.syncing && state.errorMessage == null,
        ),
        predicate<SyncState>(
          (state) =>
              state.status == SyncStatus.success && state.errorMessage == null,
        ),
      ],
      verify: (_) {
        expect(syncService.syncCalls, 1);
      },
    );
  });
}
