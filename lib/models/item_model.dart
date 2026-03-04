import 'package:hive/hive.dart';

part 'item_model.g.dart';

@HiveType(typeId: 1)
class ItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  int stockQuantity;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isActive;

  ItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  bool get isOutOfStock => stockQuantity <= 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  ItemModel copyWith({
    String? name,
    double? price,
    int? stockQuantity,
    String? categoryId,
    bool? isActive,
  }) =>
      ItemModel(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        stockQuantity: stockQuantity ?? this.stockQuantity,
        categoryId: categoryId ?? this.categoryId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        isActive: isActive ?? this.isActive,
      );
}
