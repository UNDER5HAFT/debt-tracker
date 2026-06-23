import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class AmountBadge extends StatelessWidget {
  final double amount;
  final bool isIncoming;
  final bool showSign;
  final TextStyle? textStyle;

  const AmountBadge({
    super.key,
    required this.amount,
    required this.isIncoming,
    this.showSign = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = amount == 0
        ? AppColors.neutral(context)
        : isIncoming
            ? AppColors.incoming(context)
            : AppColors.outgoing(context);

    final sign = amount == 0
        ? ''
        : showSign
            ? (isIncoming ? '+' : '-')
            : '';

    return Text(
      '$sign${AppFormatters.currency(amount.abs())}',
      style: (textStyle ?? Theme.of(context).textTheme.titleMedium)!.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
