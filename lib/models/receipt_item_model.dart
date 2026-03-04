import 'package:hive/hive.dart';

part 'receipt_item_model.g.dart';

@HiveType(typeId: 2)
class ReceiptItemModel extends HiveObject {
  @HiveField(0)
  String itemId;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double subtotal;

  ReceiptItemModel({
    required this.itemId,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });
}
