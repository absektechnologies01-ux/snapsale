import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/dashboard/sales_chart.dart';
import '../../widgets/dashboard/summary_card.dart';
import '../receipt/receipt_list_screen.dart';
import '../receipt/receipt_preview_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: AppStrings.receiptHistory,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ReceiptListScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final rp = context.read<ReceiptProvider>();
          final dp = context.read<DashboardProvider>();
          await rp.loadReceipts();
          dp.refresh(rp.allReceipts);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Text(
                DateFormatter.formatDate(DateTime.now()),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: AppStrings.todaySales,
                      total: dashboard.todayTotal,
                      count: dashboard.todayCount,
                      icon: Icons.today_outlined,
                      accentColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: AppStrings.weekSales,
                      total: dashboard.weekTotal,
                      count: dashboard.weekCount,
                      icon: Icons.calendar_view_week_outlined,
                      accentColor: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SummaryCard(
                label: AppStrings.monthSales,
                total: dashboard.monthTotal,
                count: dashboard.monthCount,
                icon: Icons.calendar_month_outlined,
                accentColor: AppColors.primaryDark,
              ),

              const SizedBox(height: 20),

              // Chart
              SalesChart(dashboard: dashboard),

              const SizedBox(height: 20),

              // Recent transactions header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.recentTransactions,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReceiptListScreen()),
                    ),
                    child: const Text(AppStrings.viewAll),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent transactions list
              if (dashboard.recentTransactions.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.noSalesYet,
                  subtitle: AppStrings.noSalesYetSub,
                )
              else
                ...dashboard.recentTransactions.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
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
                            border:
                                Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                    Icons.receipt_outlined,
                                    color: AppColors.primary,
                                    size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(r.receiptNumber,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                FontWeight.w600)),
                                    Text(
                                      DateFormatter.formatDateTime(
                                          r.createdAt),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color:
                                              AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(r.grandTotal),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary,
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
