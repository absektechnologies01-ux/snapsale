import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: '${AppStrings.currency} ',
    decimalDigits: 2,
  );

  static final _ghsFormatter = NumberFormat.currency(
    symbol: 'GHS ',
    decimalDigits: 2,
  );

  static String format(double amount) => _formatter.format(amount);

  static String formatGHS(double amount) => _ghsFormatter.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000) {
      return '${AppStrings.currency} ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount);
  }
}
