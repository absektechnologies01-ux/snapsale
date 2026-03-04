import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/receipt_model.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'receipt_preview_screen.dart';

enum _DateFilter { all, today, week, month }

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  _DateFilter _dateFilter = _DateFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ReceiptModel> _filter(List<ReceiptModel> all) {
    final now = DateTime.now();
    return all.where((r) {
      if (_query.isNotEmpty &&
          !r.receiptNumber.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      switch (_dateFilter) {
        case _DateFilter.today:
          return r.createdAt.year == now.year &&
              r.createdAt.month == now.month &&
              r.createdAt.day == now.day;
        case _DateFilter.week:
          return r.createdAt
              .isAfter(now.subtract(const Duration(days: 7)));
        case _DateFilter.month:
          return r.createdAt.year == now.year &&
              r.createdAt.month == now.month;
        case _DateFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allReceipts = context.watch<ReceiptProvider>().allReceipts;
    final receipts = _filter(allReceipts);
    final hasActiveFilter =
        _query.isNotEmpty || _dateFilter != _DateFilter.all;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.receiptHistory)),
      body: Column(
        children: [
          // Search + date filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by receipt ID…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _dateFilter == _DateFilter.all,
                        onTap: () =>
                            setState(() => _dateFilter = _DateFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Today',
                        selected: _dateFilter == _DateFilter.today,
                        onTap: () =>
                            setState(() => _dateFilter = _DateFilter.today),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'This Week',
                        selected: _dateFilter == _DateFilter.week,
                        onTap: () =>
                            setState(() => _dateFilter = _DateFilter.week),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'This Month',
                        selected: _dateFilter == _DateFilter.month,
                        onTap: () =>
                            setState(() => _dateFilter = _DateFilter.month),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),

          // Result count row
          if (allReceipts.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${receipts.length} receipt${receipts.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

          Expanded(
            child: receipts.isEmpty
                ? LayoutBuilder(
                    builder: (ctx, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: constraints.maxHeight),
                        child: EmptyStateWidget(
                          icon: Icons.receipt_long_outlined,
                          title: hasActiveFilter
                              ? 'No matching receipts'
                              : AppStrings.noSalesYet,
                          subtitle: hasActiveFilter
                              ? 'Try a different search or filter'
                              : AppStrings.noSalesYetSub,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: receipts.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = receipts[i];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReceiptPreviewScreen(receipt: r),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.receipt_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.receiptNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormatter.formatDateTime(
                                          r.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(r.grandTotal),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${r.totalItemCount} item${r.totalItemCount == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                  size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
