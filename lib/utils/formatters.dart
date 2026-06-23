import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String currency(double value) => _currencyFormat.format(value);

  static String date(DateTime date) => _dateFormat.format(date);

  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  static Object relativeSimple(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return date;
  }
}

class AppColors {
  static Color incoming(BuildContext context) => Colors.green;

  static Color outgoing(BuildContext context) => Colors.red;

  static Color neutral(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
}
