import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/receipt_provider.dart';
import 'providers/shop_settings_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/main_shell.dart';
import 'services/hive_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await SubscriptionService.init();
  runApp(const SnapSaleApp());
}

class SnapSaleApp extends StatelessWidget {
  const SnapSaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ShopSettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => ReceiptProvider()..loadReceipts(),
        ),
        ChangeNotifierProxyProvider<ReceiptProvider, DashboardProvider>(
          create: (_) => DashboardProvider(),
          update: (_, receiptProvider, dashboard) {
            dashboard!.refresh(receiptProvider.allReceipts);
            return dashboard;
          },
        ),
      ],
      child: MaterialApp(
        title: 'SnapSale',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const MainShell(),
      ),
    );
  }
}
