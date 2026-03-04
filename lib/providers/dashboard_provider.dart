import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/currency_formatter.dart';

class DashboardProvider extends ChangeNotifier {
  List<ReceiptModel> _receipts = [];

  void refresh(List<ReceiptModel> receipts) {
    _receipts = receipts;
    notifyListeners();
  }

  // ── Today ──────────────────────────────────────────────

  List<ReceiptModel> get _todayReceipts {
    final now = DateTime.now();
    return _receipts.where((r) => DateFormatter.isSameDay(r.createdAt, now)).toList();
  }

  double get todayTotal =>
      _todayReceipts.fold(0.0, (sum, r) => sum + r.grandTotal);

  int get todayCount => _todayReceipts.length;

  // ── This Week ──────────────────────────────────────────

  List<ReceiptModel> get _weekReceipts {
    final now = DateTime.now();
    return _receipts.where((r) => DateFormatter.isSameWeek(r.createdAt, now)).toList();
  }

  double get weekTotal =>
      _weekReceipts.fold(0.0, (sum, r) => sum + r.grandTotal);

  int get weekCount => _weekReceipts.length;

  // ── This Month ─────────────────────────────────────────

  List<ReceiptModel> get _monthReceipts {
    final now = DateTime.now();
    return _receipts.where((r) => DateFormatter.isSameMonth(r.createdAt, now)).toList();
  }

  double get monthTotal =>
      _monthReceipts.fold(0.0, (sum, r) => sum + r.grandTotal);

  int get monthCount => _monthReceipts.length;

  // ── Chart: last 7 days ─────────────────────────────────

  List<BarChartGroupData> get weeklyChartData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = _receipts
          .where((r) => DateFormatter.isSameDay(r.createdAt, day))
          .fold(0.0, (sum, r) => sum + r.grandTotal);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  List<String> get weeklyChartLabels {
    final now = DateTime.now();
    return List.generate(
      7,
      (i) => DateFormatter.formatDayShort(now.subtract(Duration(days: 6 - i))),
    );
  }

  double get weeklyChartMaxY {
    if (_receipts.isEmpty) return 100;
    final now = DateTime.now();
    double max = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = _receipts
          .where((r) => DateFormatter.isSameDay(r.createdAt, day))
          .fold(0.0, (sum, r) => sum + r.grandTotal);
      if (total > max) max = total;
    }
    return max == 0 ? 100 : (max * 1.3);
  }

  // ── Recent ─────────────────────────────────────────────

  List<ReceiptModel> get recentTransactions => _receipts.take(5).toList();

  String formatAmount(double amount) => CurrencyFormatter.format(amount);
}
