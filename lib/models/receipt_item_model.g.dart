// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptItemModelAdapter extends TypeAdapter<ReceiptItemModel> {
  @override
  final int typeId = 2;

  @override
  ReceiptItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptItemModel(
      itemId: fields[0] as String,
      itemName: fields[1] as String,
      unitPrice: fields[2] as double,
      quantity: fields[3] as int,
      subtotal: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.unitPrice)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.subtotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
