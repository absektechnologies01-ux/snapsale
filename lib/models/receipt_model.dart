import 'package:hive/hive.dart';
import 'receipt_item_model.dart';

part 'receipt_model.g.dart';

@HiveType(typeId: 3)
class ReceiptModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String receiptNumber;

  @HiveField(2)
  List<ReceiptItemModel> items;

  @HiveField(3)
  double grandTotal;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String shopName;

  @HiveField(6)
  String shopAddress;

  @HiveField(7)
  String shopPhone;

  @HiveField(8)
  String shopEmail;

  @HiveField(9)
  String? shopLogoPath;

  ReceiptModel({
    required this.id,
    required this.receiptNumber,
    required this.items,
    required this.grandTotal,
    required this.createdAt,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    required this.shopEmail,
    this.shopLogoPath,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);
}
