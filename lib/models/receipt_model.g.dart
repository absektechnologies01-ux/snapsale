// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptModelAdapter extends TypeAdapter<ReceiptModel> {
  @override
  final int typeId = 3;

  @override
  ReceiptModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptModel(
      id: fields[0] as String,
      receiptNumber: fields[1] as String,
      items: (fields[2] as List).cast<ReceiptItemModel>(),
      grandTotal: fields[3] as double,
      createdAt: fields[4] as DateTime,
      shopName: fields[5] as String,
      shopAddress: fields[6] as String,
      shopPhone: fields[7] as String,
      shopEmail: fields[8] as String,
      shopLogoPath: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.receiptNumber)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.grandTotal)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.shopName)
      ..writeByte(6)
      ..write(obj.shopAddress)
      ..writeByte(7)
      ..write(obj.shopPhone)
      ..writeByte(8)
      ..write(obj.shopEmail)
      ..writeByte(9)
      ..write(obj.shopLogoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
