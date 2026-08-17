import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_sync_status.dart';
import '../bloc/inspections_history_bloc.dart';

class InspectionsHistoryPage extends StatefulWidget {
  const InspectionsHistoryPage({super.key});

  @override
  State<InspectionsHistoryPage> createState() => _InspectionsHistoryPageState();
}

class _InspectionsHistoryPageState extends State<InspectionsHistoryPage> {
  @override
  void initState() {
    super.initState();

    context.read<InspectionsHistoryBloc>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de inspeções'),
        actions: [
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              if (state.status == SyncStatus.syncing) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return IconButton(
                onPressed: () {
                  context.read<SyncBloc>().add(const SyncRequested());
                },
                icon: const Icon(Icons.sync),
                tooltip: 'Sincronizar',
              );
            },
          ),
        ],
      ),
      body: BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state.status == SyncStatus.success ||
              state.status == SyncStatus.failure) {
            context.read<InspectionsHistoryBloc>().refresh();
          }
        },
        child: Column(
          children: [
            _StatusFilter(),
            Expanded(
              child:
                  BlocBuilder<InspectionsHistoryBloc, InspectionsHistoryState>(
                    builder: (context, state) {
                      switch (state.status) {
                        case InspectionsHistoryStatus.initial:
                        case InspectionsHistoryStatus.loading:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        case InspectionsHistoryStatus.failure:
                          return _ErrorState(
                            message: state.errorMessage,
                            onRetry: () {
                              context.read<InspectionsHistoryBloc>().load();
                            },
                          );

                        case InspectionsHistoryStatus.success:
                          if (state.inspections.isEmpty) {
                            return const _EmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: () {
                              return context
                                  .read<InspectionsHistoryBloc>()
                                  .refresh();
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.inspections.length,
                              itemBuilder: (context, index) {
                                return _InspectionCard(
                                  inspection: state.inspections[index],
                                  onRetry: () {
                                    context.read<SyncBloc>().add(
                                      const SyncRetryFailedRequested(),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                      }
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: BlocBuilder<InspectionsHistoryBloc, InspectionsHistoryState>(
        builder: (context, state) {
          return DropdownButtonFormField<InspectionSyncStatus?>(
            initialValue: state.filter,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todos')),
              DropdownMenuItem(
                value: InspectionSyncStatus.draft,
                child: Text('Rascunhos'),
              ),
              DropdownMenuItem(
                value: InspectionSyncStatus.pending,
                child: Text('Pendentes'),
              ),
              DropdownMenuItem(
                value: InspectionSyncStatus.synced,
                child: Text('Sincronizadas'),
              ),
              DropdownMenuItem(
                value: InspectionSyncStatus.failed,
                child: Text('Com falha'),
              ),
            ],
            onChanged: (value) {
              context.read<InspectionsHistoryBloc>().filterBy(value);
            },
          );
        },
      ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onRetry;

  const _InspectionCard({required this.inspection, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final status = inspection.syncStatus;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OS: ${inspection.workOrderId}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              inspection.observation,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatusIcon(status: status),
                const SizedBox(width: 8),
                Text(
                  _statusLabel(status),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (status == InspectionSyncStatus.failed &&
                inspection.syncError != null) ...[
              const SizedBox(height: 8),
              Text(
                inspection.syncError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(InspectionSyncStatus status) {
    switch (status) {
      case InspectionSyncStatus.draft:
        return 'Rascunho';

      case InspectionSyncStatus.pending:
        return 'Pendente de sincronização';

      case InspectionSyncStatus.synced:
        return 'Sincronizada';

      case InspectionSyncStatus.failed:
        return 'Falha na sincronização';
    }
  }
}

class _StatusIcon extends StatelessWidget {
  final InspectionSyncStatus status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case InspectionSyncStatus.draft:
        return const Icon(Icons.edit_outlined);

      case InspectionSyncStatus.pending:
        return const Icon(Icons.cloud_upload_outlined);

      case InspectionSyncStatus.synced:
        return const Icon(Icons.cloud_done_outlined);

      case InspectionSyncStatus.failed:
        return Icon(
          Icons.cloud_off,
          color: Theme.of(context).colorScheme.error,
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nenhuma inspeção encontrada.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar '
              'as inspeções.',
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
