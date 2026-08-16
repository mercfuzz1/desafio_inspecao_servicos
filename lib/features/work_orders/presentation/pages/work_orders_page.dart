import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../inspections/domain/repositories/inspections_repository.dart';
import '../../../inspections/presentation/pages/inspections_history_page.dart';
import '../bloc/work_orders_bloc.dart';
import '../bloc/work_orders_event.dart';
import '../bloc/work_orders_state.dart';
import '../widgets/work_order_card.dart';
import 'work_order_detail_page.dart';

import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';

class WorkOrdersPage extends StatefulWidget {
  final InspectionsRepository inspectionsRepository;

  const WorkOrdersPage({super.key, required this.inspectionsRepository});

  @override
  State<WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends State<WorkOrdersPage> {
  @override
  void initState() {
    super.initState();

    context.read<WorkOrdersBloc>().add(const WorkOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
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
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InspectionsHistoryPage(),
                ),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de inspeções',
          ),
        ],
      ),
      body: BlocBuilder<WorkOrdersBloc, WorkOrdersState>(
        builder: (context, state) {
          switch (state.status) {
            case WorkOrdersStatus.initial:
            case WorkOrdersStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case WorkOrdersStatus.empty:
              return _EmptyState(
                onRetry: () {
                  context.read<WorkOrdersBloc>().add(
                    const WorkOrdersRequested(),
                  );
                },
              );

            case WorkOrdersStatus.failure:
              return _ErrorState(
                message: state.errorMessage,
                onRetry: () {
                  context.read<WorkOrdersBloc>().add(
                    const WorkOrdersRequested(),
                  );
                },
              );

            case WorkOrdersStatus.refreshing:
            case WorkOrdersStatus.success:
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WorkOrdersBloc>().add(
                    const WorkOrdersRefreshRequested(),
                  );

                  await context.read<WorkOrdersBloc>().stream.firstWhere(
                    (state) =>
                        state.status == WorkOrdersStatus.success ||
                        state.status == WorkOrdersStatus.empty ||
                        state.status == WorkOrdersStatus.failure,
                  );
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.workOrders.length,
                  itemBuilder: (context, index) {
                    final workOrder = state.workOrders[index];

                    return WorkOrderCard(
                      workOrder: workOrder,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WorkOrderDetailPage(
                              workOrder: workOrder,
                              inspectionsRepository:
                                  widget.inspectionsRepository,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma ordem de serviço encontrada.',
              textAlign: TextAlign.center,
            ),
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
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Não foi possível carregar as ordens de serviço.',
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
