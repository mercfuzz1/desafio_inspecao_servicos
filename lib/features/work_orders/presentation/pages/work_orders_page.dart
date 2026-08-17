import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../../../inspections/domain/repositories/inspections_repository.dart';
import '../../../inspections/presentation/pages/inspections_history_page.dart';

import '../../../sync/presentation/bloc/sync_bloc.dart';
import '../../../sync/presentation/bloc/sync_event.dart';
import '../../../sync/presentation/bloc/sync_state.dart';

import '../bloc/work_orders_bloc.dart';
import '../bloc/work_orders_event.dart';
import '../bloc/work_orders_state.dart';
import '../widgets/work_order_card.dart';
import 'work_order_detail_page.dart';
import '../../../../core/theme/theme_controller.dart';


class WorkOrdersPage extends StatefulWidget {
  final InspectionsRepository inspectionsRepository;
  final ThemeController themeController;

  const WorkOrdersPage({
    super.key,
    required this.inspectionsRepository,
    required this.themeController,
  });

  @override
  State<WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends State<WorkOrdersPage> {
  @override
  void initState() {
    super.initState();

    context.read<WorkOrdersBloc>().add(const WorkOrdersRequested());
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

@override
Widget build(BuildContext context) {
  return MultiBlocListener(
    listeners: [
      BlocListener<SyncBloc, SyncState>(
        listener: (context, state) {
          if (state.status == SyncStatus.success) {
            _showMessage(
              'Suas inspeções estão sincronizadas.',
            );
          }

          if (state.status == SyncStatus.failure) {
            _showMessage(
              state.errorMessage ??
                  'Algo deu errado na sincronização.',
            );
          }
        },
      ),
    ],
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),

        actions: [
          // ==================================================
          // SINCRONIZAÇÃO
          // ==================================================

          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              if (state.status == SyncStatus.syncing) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }

              return IconButton(
                onPressed: () {
                  context.read<SyncBloc>().add(
                    const SyncRequested(),
                  );
                },
                icon: const Icon(
                  Icons.sync,
                ),
                tooltip: 'Sincronizar',
              );
            },
          ),

          // ==================================================
          // MENU
          // ==================================================

          PopupMenuButton<String>(
            onSelected: (value) {
              // ------------------------------------------------
              // HISTÓRICO
              // ------------------------------------------------

              if (value == 'history') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const InspectionsHistoryPage(),
                  ),
                );
              }

              // ------------------------------------------------
              // TEMA
              // ------------------------------------------------

              if (value == 'theme') {
                widget.themeController.toggleTheme();
              }

              // ------------------------------------------------
              // LOGOUT
              // ------------------------------------------------

              if (value == 'logout') {
                context.read<AuthBloc>().add(
                  const AuthLogoutRequested(),
                );
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'history',
                child: ListTile(
                  leading: Icon(
                    Icons.history,
                  ),
                  title: Text(
                    'Histórico de inspeções',
                  ),
                ),
              ),

              PopupMenuItem<String>(
                value: 'theme',
                child: ListTile(
                  leading: Icon(
                    widget.themeController.isDark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  title: Text(
                    widget.themeController.isDark
                        ? 'Modo claro'
                        : 'Modo escuro',
                  ),
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                  ),
                  title: Text(
                    'Sair',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ======================================================
      // WORK ORDERS
      // ======================================================

      body: BlocBuilder<WorkOrdersBloc, WorkOrdersState>(
        builder: (context, state) {
          switch (state.status) {
            case WorkOrdersStatus.initial:
            case WorkOrdersStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );

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

                  await context
                      .read<WorkOrdersBloc>()
                      .stream
                      .firstWhere(
                        (state) =>
                            state.status ==
                                WorkOrdersStatus.success ||
                            state.status ==
                                WorkOrdersStatus.empty ||
                            state.status ==
                                WorkOrdersStatus.failure,
                      );

                  if (!mounted) {
                    return;
                  }

                  final currentState =
                      context
                          .read<WorkOrdersBloc>()
                          .state;

                  if (currentState.errorMessage != null) {
                    _showMessage(
                      currentState.errorMessage!,
                    );
                  } else if (currentState.status ==
                      WorkOrdersStatus.success) {
                    _showMessage(
                      'Ordens de serviço atualizadas com sucesso.',
                    );
                  } else if (currentState.status ==
                      WorkOrdersStatus.empty) {
                    _showMessage(
                      'A lista foi atualizada, mas nenhuma ordem de serviço foi encontrada.',
                    );
                  }
                },

                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      state.workOrders.length,
                  itemBuilder:
                      (context, index) {
                    final workOrder =
                        state.workOrders[index];

                    return WorkOrderCard(
                      workOrder: workOrder,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkOrderDetailPage(
                              workOrder:
                                  workOrder,
                              inspectionsRepository:
                                  widget
                                      .inspectionsRepository,
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
