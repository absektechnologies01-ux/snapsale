import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../services/hive_service.dart';

class CatalogProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ItemModel> _items = [];
  String? _selectedCategoryId;
  String _searchQuery = '';

  static const _uuid = Uuid();

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  List<ItemModel> get filteredItems {
    var items = _items.where((i) => i.isActive).toList();
    if (_selectedCategoryId != null) {
      items = items.where((i) => i.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) => i.name.toLowerCase().contains(q)).toList();
    }
    return items;
  }

  List<ItemModel> get allActiveItems =>
      _items.where((i) => i.isActive).toList();

  Future<void> loadAll() async {
    _categories = HiveService.categoriesBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _items = HiveService.itemsBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  // ── Categories ──────────────────────────────────────────

  Future<void> addCategory(String name, {String? iconEmoji}) async {
    final cat = CategoryModel(
      id: _uuid.v4(),
      name: name,
      iconEmoji: iconEmoji,
      createdAt: DateTime.now(),
    );
    await HiveService.categoriesBox.put(cat.id, cat);
    _categories.add(cat);
    notifyListeners();
  }

  Future<void> updateCategory(
      CategoryModel cat, String name, String? iconEmoji) async {
    final updated = cat.copyWith(name: name, iconEmoji: iconEmoji);
    await HiveService.categoriesBox.put(cat.id, updated);
    final idx = _categories.indexWhere((c) => c.id == cat.id);
    if (idx != -1) _categories[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await HiveService.categoriesBox.delete(id);
    _categories.removeWhere((c) => c.id == id);
    // Move items in deleted category to empty categoryId
    final affected = _items.where((i) => i.categoryId == id).toList();
    for (final item in affected) {
      final updated = item.copyWith(categoryId: '');
      await HiveService.itemsBox.put(item.id, updated);
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx != -1) _items[idx] = updated;
    }
    if (_selectedCategoryId == id) _selectedCategoryId = null;
    notifyListeners();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int itemCountForCategory(String categoryId) =>
      _items.where((i) => i.isActive && i.categoryId == categoryId).length;

  // ── Items ────────────────────────────────────────────────

  Future<void> addItem({
    required String name,
    required double price,
    required int stockQuantity,
    required String categoryId,
  }) async {
    final now = DateTime.now();
    final item = ItemModel(
      id: _uuid.v4(),
      name: name,
      price: price,
      stockQuantity: stockQuantity,
      categoryId: categoryId,
      createdAt: now,
      updatedAt: now,
    );
    await HiveService.itemsBox.put(item.id, item);
    _items.add(item);
    notifyListeners();
  }

  Future<void> updateItem(
    ItemModel item, {
    required String name,
    required double price,
    required int stockQuantity,
    required String categoryId,
  }) async {
    final updated = item.copyWith(
      name: name,
      price: price,
      stockQuantity: stockQuantity,
      categoryId: categoryId,
    );
    await HiveService.itemsBox.put(item.id, updated);
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) _items[idx] = updated;
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    final item = _items.firstWhere((i) => i.id == id);
    final updated = item.copyWith(isActive: false);
    await HiveService.itemsBox.put(id, updated);
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) _items[idx] = updated;
    notifyListeners();
  }

  Future<void> deductStock(String itemId, int quantity) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    final item = _items[idx];
    final newQty = (item.stockQuantity - quantity).clamp(0, 999999);
    final updated = item.copyWith(stockQuantity: newQty);
    await HiveService.itemsBox.put(itemId, updated);
    _items[idx] = updated;
    notifyListeners();
  }

  void setFilter(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilter() {
    _selectedCategoryId = null;
    _searchQuery = '';
    notifyListeners();
  }
}
