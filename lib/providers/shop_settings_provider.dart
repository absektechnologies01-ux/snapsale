import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/shop_settings_model.dart';
import '../services/hive_service.dart';
import '../core/utils/receipt_number_gen.dart';

class ShopSettingsProvider extends ChangeNotifier {
  ShopSettingsModel _settings = ShopSettingsModel();
  ShopSettingsModel get settings => _settings;
  bool get isConfigured => _settings.isConfigured;

  Future<void> load() async {
    final box = HiveService.settingsBox;
    final stored = box.get(HiveService.settingsKey);
    if (stored != null) {
      _settings = stored;
    }
    notifyListeners();
  }

  Future<void> save({
    required String shopName,
    required String address,
    required String phone,
    required String email,
  }) async {
    _settings = _settings.copyWith(
      shopName: shopName,
      address: address,
      phone: phone,
      email: email,
    );
    await HiveService.settingsBox.put(HiveService.settingsKey, _settings);
    notifyListeners();
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      _settings = _settings.copyWith(logoPath: image.path);
      await HiveService.settingsBox.put(HiveService.settingsKey, _settings);
      notifyListeners();
    }
  }

  Future<int> incrementReceiptCounter() async {
    final newCounter = _settings.receiptCounter + 1;
    _settings = _settings.copyWith(receiptCounter: newCounter);
    await HiveService.settingsBox.put(HiveService.settingsKey, _settings);
    notifyListeners();
    return newCounter;
  }

  String get nextReceiptNumber =>
      ReceiptNumberGen.generate(_settings.receiptCounter + 1);
}
