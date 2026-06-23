import 'package:flutter/material.dart';

import '../models/person.dart';
import '../utils/formatters.dart';
import 'amount_badge.dart';

class PersonCard extends StatelessWidget {
  final Person person;
  final double balance;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PersonCard({
    super.key,
    required this.person,
    required this.balance,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncoming = balance > 0;
    final isZero = balance == 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isZero
              ? AppColors.neutral(context).withValues(alpha: 0.2)
              : isIncoming
              ? AppColors.incoming(context).withValues(alpha: 0.2)
              : AppColors.outgoing(context).withValues(alpha: 0.2),
          child: Icon(
            Icons.person,
            color: isZero
                ? AppColors.neutral(context)
                : isIncoming
                ? AppColors.incoming(context)
                : AppColors.outgoing(context),
          ),
        ),
        title: Text(
          person.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isZero
              ? 'Sin deudas activas'
              : isIncoming
              ? 'Te debe ${AppFormatters.currency(balance.abs())}'
              : 'Le debes ${AppFormatters.currency(balance.abs())}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AmountBadge(
              amount: balance.abs(),
              isIncoming: isIncoming,
              showSign: true,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
              tooltip: 'Eliminar persona',
            ),
          ],
        ),
      ),
    );
  }
}
