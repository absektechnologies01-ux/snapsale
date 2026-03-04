import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/catalog/category_chip.dart';
import '../../widgets/catalog/item_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'cart_review_screen.dart';

class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.watch<CartProvider>();
    final items = catalog.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newSaleTitle),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: AppStrings.clearCart,
              onPressed: () => context.read<CartProvider>().clearCart(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search + filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => catalog.setSearch(v),
                  decoration: InputDecoration(
                    hintText: AppStrings.search,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              catalog.setSearch('');
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
                if (catalog.categories.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryChipWidget(
                          label: AppStrings.allCategories,
                          isSelected: catalog.selectedCategoryId == null,
                          onTap: () => catalog.setFilter(null),
                        ),
                        ...catalog.categories.map((c) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: CategoryChipWidget(
                                label: c.name,
                                emoji: c.iconEmoji,
                                isSelected:
                                    catalog.selectedCategoryId == c.id,
                                onTap: () => catalog.setFilter(c.id),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Items grid
          Expanded(
            child: items.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.noItemsFound,
                    subtitle: AppStrings.noItemsFoundSub,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final cat =
                          catalog.getCategoryById(item.categoryId);
                      return ItemCard(
                        item: item,
                        categoryName: cat?.name ?? 'Uncategorized',
                        inSaleMode: true,
                        onAddToCart: () =>
                            context.read<CartProvider>().addItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Sticky bottom bar
      bottomSheet: cart.isEmpty
          ? null
          : _CartBottomBar(cart: cart),
    );
  }
}

class _CartBottomBar extends StatelessWidget {
  final CartProvider cart;
  const _CartBottomBar({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '${cart.itemCount}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              CurrencyFormatter.format(cart.grandTotal),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CartReviewScreen()),
            ),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text(AppStrings.viewCart),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
