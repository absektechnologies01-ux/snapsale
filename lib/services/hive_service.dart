import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/item_model.dart';
import '../models/receipt_item_model.dart';
import '../models/receipt_model.dart';
import '../models/shop_settings_model.dart';

class HiveService {
  static const String _categoriesBox = 'categories';
  static const String _itemsBox = 'items';
  static const String _receiptsBox = 'receipts';
  static const String _settingsBox = 'shop_settings';
  static const String _settingsKey = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(ItemModelAdapter());
    Hive.registerAdapter(ReceiptItemModelAdapter());
    Hive.registerAdapter(ReceiptModelAdapter());
    Hive.registerAdapter(ShopSettingsModelAdapter());

    await Hive.openBox<CategoryModel>(_categoriesBox);
    await Hive.openBox<ItemModel>(_itemsBox);
    await Hive.openBox<ReceiptModel>(_receiptsBox);
    await Hive.openBox<ShopSettingsModel>(_settingsBox);
    // Subscription box (untyped — stores ISO date strings and strings)
    await Hive.openBox('subscription');
  }

  static Box<CategoryModel> get categoriesBox =>
      Hive.box<CategoryModel>(_categoriesBox);

  static Box<ItemModel> get itemsBox => Hive.box<ItemModel>(_itemsBox);

  static Box<ReceiptModel> get receiptsBox =>
      Hive.box<ReceiptModel>(_receiptsBox);

  static Box<ShopSettingsModel> get settingsBox =>
      Hive.box<ShopSettingsModel>(_settingsBox);

  static String get settingsKey => _settingsKey;
}
