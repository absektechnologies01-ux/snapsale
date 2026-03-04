import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/category_model.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/catalog/category_chip.dart';
import '../../widgets/catalog/item_card.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import 'add_edit_category_screen.dart';
import 'add_edit_item_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.catalog),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: AppStrings.items),
            Tab(text: AppStrings.categories),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ItemsTab(),
          _CategoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditItemScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AddEditCategoryScreen()),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(
            _tabController.index == 0
                ? AppStrings.addItem
                : AppStrings.addCategory),
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  const _ItemsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchAndFilter(),
        const Expanded(child: _ItemsGrid()),
      ],
    );
  }
}

class _SearchAndFilter extends StatefulWidget {
  @override
  State<_SearchAndFilter> createState() => _SearchAndFilterState();
}

class _SearchAndFilterState extends State<_SearchAndFilter> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                          isSelected: catalog.selectedCategoryId == c.id,
                          onTap: () => catalog.setFilter(c.id),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsGrid extends StatelessWidget {
  const _ItemsGrid();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final items = catalog.filteredItems;

    if (items.isEmpty) {
      return LayoutBuilder(
        builder: (ctx, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: AppStrings.noItemsFound,
              subtitle: AppStrings.noItemsFoundSub,
              actionLabel: AppStrings.addItem,
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final cat = catalog.getCategoryById(item.categoryId);
        return ItemCard(
          item: item,
          categoryName: cat?.name ?? 'Uncategorized',
          onEdit: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddEditItemScreen(item: item)),
          ),
          onDelete: () async {
            final ok = await showConfirmDialog(
              context,
              title: AppStrings.deleteConfirmTitle,
              message: 'Delete "${item.name}"?',
            );
            if (ok && context.mounted) {
              await context.read<CatalogProvider>().deleteItem(item.id);
            }
          },
        );
      },
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cats = catalog.categories;

    if (cats.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.category_outlined,
        title: 'No categories yet',
        subtitle: 'Add categories to organise your items',
        actionLabel: AppStrings.addCategory,
        onAction: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddEditCategoryScreen()),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cats.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final cat = cats[i];
        final count = catalog.itemCountForCategory(cat.id);
        return _CategoryTile(cat: cat, itemCount: count);
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel cat;
  final int itemCount;
  const _CategoryTile({required this.cat, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: cat.iconEmoji != null
              ? Text(cat.iconEmoji!, style: const TextStyle(fontSize: 20))
              : const Icon(Icons.category_outlined,
                  color: AppColors.primary, size: 20),
        ),
        title: Text(cat.name,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.textSecondary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddEditCategoryScreen(category: cat)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: AppStrings.deleteConfirmTitle,
                  message:
                      'Delete "${cat.name}"? Items will become uncategorized.',
                );
                if (ok && context.mounted) {
                  await context
                      .read<CatalogProvider>()
                      .deleteCategory(cat.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
