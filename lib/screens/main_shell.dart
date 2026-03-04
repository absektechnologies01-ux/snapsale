import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/payment_config.dart';
import '../providers/cart_provider.dart';
import '../providers/subscription_provider.dart';
import 'catalog/catalog_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'sale/new_sale_screen.dart';
import 'settings/settings_screen.dart';
import 'subscription/payment_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    CatalogScreen(),
    NewSaleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final sub = context.watch<SubscriptionProvider>();

    // ── Hard gate: subscription expired past grace period ─────────────────
    if (sub.isBlocked) {
      return const PaymentScreen(isGate: true);
    }

    return Scaffold(
      body: Column(
        children: [
          // ── Subtle warning banner (7 days before expiry OR grace period) ─
          if (sub.isDueSoon || sub.isInGracePeriod)
            _SubscriptionBanner(sub: sub),

          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: AppStrings.dashboard,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: AppStrings.catalog,
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.point_of_sale_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.point_of_sale_rounded),
            label: AppStrings.newSale,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store_rounded),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}

// ── Warning banner shown when subscription is expiring / in grace period ──────

class _SubscriptionBanner extends StatelessWidget {
  final SubscriptionProvider sub;
  const _SubscriptionBanner({required this.sub});

  @override
  Widget build(BuildContext context) {
    final isGrace = sub.isInGracePeriod;
    final color = isGrace ? AppColors.error : AppColors.warningAmber;

    final message = isGrace
        ? 'Subscription expired — ${PaymentConfig.graceDays - sub.daysOverdue}d left before access is paused'
        : 'Subscription expires in ${sub.daysUntilExpiry}d — tap to renew';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentScreen()),
      ),
      child: Container(
        width: double.infinity,
        color: color,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              isGrace
                  ? Icons.warning_amber_rounded
                  : Icons.notifications_outlined,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Text(
              'Renew →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
