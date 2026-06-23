import 'package:flutter/material.dart';

import '../models/debt.dart';
import '../models/debt_type.dart';
import '../utils/formatters.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DebtCard({
    super.key,
    required this.debt,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = debt.type == DebtType.theyOweMe;
    final color = debt.isPaid
        ? AppColors.neutral(context)
        : isIncoming
        ? AppColors.incoming(context)
        : AppColors.outgoing(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(
          debt.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: debt.isPaid ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${debt.type.label} • ${AppFormatters.date(debt.date)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (debt.dueDate != null)
              Text(
                'Vence: ${AppFormatters.date(debt.dueDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isOverdue(debt) ? Colors.orange : null,
                  fontWeight: _isOverdue(debt) ? FontWeight.bold : null,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppFormatters.currency(debt.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                decoration: debt.isPaid ? TextDecoration.lineThrough : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Editar deuda',
            ),
            IconButton(
              icon: Icon(
                debt.isPaid ? Icons.replay : Icons.check_circle_outline,
                color: debt.isPaid ? Colors.grey : Colors.green,
              ),
              onPressed: onTogglePaid,
              tooltip: debt.isPaid ? 'Reactivar deuda' : 'Marcar como pagada',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: 'Eliminar deuda',
            ),
          ],
        ),
      ),
    );
  }

  bool _isOverdue(Debt debt) {
    if (debt.isPaid || debt.dueDate == null) return false;
    return DateTime.now().isAfter(debt.dueDate!);
  }
}
