import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/item_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get grandTotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  void addItem(ItemModel item) {
    final idx = _items.indexWhere((c) => c.item.id == item.id);
    if (idx != -1) {
      final existing = _items[idx];
      if (existing.quantity < item.stockQuantity) {
        _items[idx] = existing.copyWith(quantity: existing.quantity + 1);
      }
    } else {
      _items.add(CartItemModel(item: item));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((c) => c.item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int qty) {
    final idx = _items.indexWhere((c) => c.item.id == itemId);
    if (idx == -1) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      final maxQty = _items[idx].item.stockQuantity;
      _items[idx] = _items[idx].copyWith(quantity: qty.clamp(1, maxQty));
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
