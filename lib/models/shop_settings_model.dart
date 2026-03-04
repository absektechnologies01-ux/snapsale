import 'package:hive/hive.dart';

part 'shop_settings_model.g.dart';

@HiveType(typeId: 4)
class ShopSettingsModel extends HiveObject {
  @HiveField(0)
  String shopName;

  @HiveField(1)
  String address;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  String? logoPath;

  @HiveField(5)
  int receiptCounter;

  ShopSettingsModel({
    this.shopName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.logoPath,
    this.receiptCounter = 0,
  });

  bool get isConfigured => shopName.isNotEmpty;

  ShopSettingsModel copyWith({
    String? shopName,
    String? address,
    String? phone,
    String? email,
    String? logoPath,
    int? receiptCounter,
  }) =>
      ShopSettingsModel(
        shopName: shopName ?? this.shopName,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        logoPath: logoPath ?? this.logoPath,
        receiptCounter: receiptCounter ?? this.receiptCounter,
      );
}
