import 'package:flutter/material.dart';

import '../../domain/entities/work_order.dart';

class WorkOrderCard extends StatelessWidget {
  final WorkOrder workOrder;
  final VoidCallback? onTap;

  const WorkOrderCard({
    super.key,
    required this.workOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workOrder.code,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  _PriorityBadge(
                    priority: workOrder.priority,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                workOrder.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 8),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(workOrder.address),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _StatusBadge(
                status: workOrder.status,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({
    required this.priority,
  });

  String _translatePriority() {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Baixa';

      case 'medium':
        return 'Média';

      case 'high':
        return 'Alta';

      case 'critical':
        return 'Crítica';

      default:
        return priority;
    }
  }

  Color _getColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;

      case 'medium':
        return Colors.orange;

      case 'high':
        return Colors.deepOrange;

      case 'critical':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _translatePriority(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  String _translateStatus() {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Aberta';

      case 'in_progress':
        return 'Em andamento';

      case 'pending':
        return 'Pendente';

      case 'completed':
        return 'Concluída';

      case 'cancelled':
        return 'Cancelada';

      case 'closed':
        return 'Fechada';

      case 'done':
        return 'Finalizada';

      default:
        return status;
    }
  }

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'open':
      case 'in_progress':
        return Colors.blue;

      case 'pending':
        return Colors.orange;

      case 'completed':
      case 'closed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        Icons.circle,
        size: 10,
        color: _statusColor(),
      ),
      label: Text(
        _translateStatus().toUpperCase(),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}