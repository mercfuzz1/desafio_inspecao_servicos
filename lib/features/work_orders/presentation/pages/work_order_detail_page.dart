import 'package:flutter/material.dart';

import '../../domain/entities/work_order.dart';

class WorkOrderDetailPage extends StatelessWidget {
  final WorkOrder workOrder;

  const WorkOrderDetailPage({
    super.key,
    required this.workOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workOrder.code),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            workOrder.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          _InfoSection(
            title: 'Descrição',
            value: workOrder.description,
          ),
          _InfoSection(
            title: 'Local',
            value: workOrder.address,
          ),
          _InfoSection(
            title: 'Prioridade',
            value: workOrder.priority.toUpperCase(),
          ),
          _InfoSection(
            title: 'Status',
            value: workOrder.status.toUpperCase(),
          ),
          _InfoSection(
            title: 'Latitude',
            value: workOrder.latitude.toString(),
          ),
          _InfoSection(
            title: 'Longitude',
            value: workOrder.longitude.toString(),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              // Próxima etapa:
              // abrir formulário de inspeção.
            },
            icon: const Icon(Icons.assignment),
            label: const Text('Iniciar inspeção'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String value;

  const _InfoSection({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyLarge,
          ),
        ],
      ),
    );
  }
}