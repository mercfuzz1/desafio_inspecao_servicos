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
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge,
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
                    child: Text(
                      workOrder.address,
                    ),
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

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        priority.toUpperCase(),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(
        Icons.circle,
        size: 10,
      ),
      label: Text(
        status.toUpperCase(),
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}