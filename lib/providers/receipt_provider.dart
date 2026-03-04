import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/cart_item_model.dart';
import '../models/receipt_item_model.dart';
import '../models/receipt_model.dart';
import '../models/shop_settings_model.dart';
import '../services/hive_service.dart';
import '../core/utils/receipt_number_gen.dart';

class ReceiptProvider extends ChangeNotifier {
  List<ReceiptModel> _receipts = [];
  static const _uuid = Uuid();

  List<ReceiptModel> get allReceipts => List.unmodifiable(_receipts);

  List<ReceiptModel> get recentReceipts =>
      _receipts.take(10).toList();

  Future<void> loadReceipts() async {
    _receipts = HiveService.receiptsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<ReceiptModel> finalizeReceipt({
    required List<CartItemModel> cartItems,
    required ShopSettingsModel settings,
    required int receiptCounter,
  }) async {
    final receiptItems = cartItems
        .map((c) => ReceiptItemModel(
              itemId: c.item.id,
              itemName: c.item.name,
              unitPrice: c.item.price,
              quantity: c.quantity,
              subtotal: c.subtotal,
            ))
        .toList();

    final receipt = ReceiptModel(
      id: _uuid.v4(),
      receiptNumber: ReceiptNumberGen.generate(receiptCounter),
      items: receiptItems,
      grandTotal: cartItems.fold(0.0, (sum, c) => sum + c.subtotal),
      createdAt: DateTime.now(),
      shopName: settings.shopName,
      shopAddress: settings.address,
      shopPhone: settings.phone,
      shopEmail: settings.email,
      shopLogoPath: settings.logoPath,
    );

    await HiveService.receiptsBox.put(receipt.id, receipt);
    _receipts.insert(0, receipt);
    notifyListeners();
    return receipt;
  }

  Future<void> deleteReceipt(String id) async {
    await HiveService.receiptsBox.delete(id);
    _receipts.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  ReceiptModel? getById(String id) {
    try {
      return _receipts.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
