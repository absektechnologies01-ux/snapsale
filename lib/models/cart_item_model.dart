import 'item_model.dart';

class CartItemModel {
  final ItemModel item;
  int quantity;

  CartItemModel({required this.item, this.quantity = 1});

  double get subtotal => item.price * quantity;

  CartItemModel copyWith({int? quantity}) =>
      CartItemModel(item: item, quantity: quantity ?? this.quantity);
}
