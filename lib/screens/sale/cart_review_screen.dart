import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/shop_settings_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/sale/cart_item_tile.dart';
import '../receipt/receipt_preview_screen.dart';

class CartReviewScreen extends StatefulWidget {
  const CartReviewScreen({super.key});

  @override
  State<CartReviewScreen> createState() => _CartReviewScreenState();
}

class _CartReviewScreenState extends State<CartReviewScreen> {
  bool _generating = false;

  Future<void> _generateReceipt() async {
    if (_generating) return;
    setState(() => _generating = true);

    final cart = context.read<CartProvider>();
    final settings = context.read<ShopSettingsProvider>();
    final receiptProvider = context.read<ReceiptProvider>();
    final catalogProvider = context.read<CatalogProvider>();
    final dashboard = context.read<DashboardProvider>();

    // Increment counter first
    final counter = await settings.incrementReceiptCounter();

    // Deduct stock for each cart item
    for (final cartItem in cart.items) {
      await catalogProvider.deductStock(
          cartItem.item.id, cartItem.quantity);
    }

    // Finalize and save receipt
    final receipt = await receiptProvider.finalizeReceipt(
      cartItems: cart.items,
      settings: settings.settings,
      receiptCounter: counter,
    );

    // Refresh dashboard
    dashboard.refresh(receiptProvider.allReceipts);

    // Clear cart
    cart.clearCart();

    setState(() => _generating = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(receipt: receipt),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cartReview),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () {
                context.read<CartProvider>().clearCart();
                Navigator.pop(context);
              },
              child: const Text(AppStrings.clearCart,
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.cartEmpty,
              subtitle: AppStrings.cartEmptySub,
              actionLabel: 'Back to Sale',
              onAction: () => Navigator.pop(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: cart.items.length,
              itemBuilder: (context, i) {
                final cartItem = cart.items[i];
                return CartItemTile(
                  cartItem: cartItem,
                  onQuantityChanged: (qty) => context
                      .read<CartProvider>()
                      .updateQuantity(cartItem.item.id, qty),
                  onRemove: () => context
                      .read<CartProvider>()
                      .removeItem(cartItem.item.id),
                );
              },
            ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary),
                      ),
                      Text(
                        CurrencyFormatter.format(cart.grandTotal),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _generating ? null : _generateReceipt,
                    icon: _generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : const Icon(Icons.receipt_long_outlined,
                            size: 18),
                    label: const Text(AppStrings.generateReceipt),
                  ),
                ],
              ),
            ),
    );
  }
}
