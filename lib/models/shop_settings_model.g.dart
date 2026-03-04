// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopSettingsModelAdapter extends TypeAdapter<ShopSettingsModel> {
  @override
  final int typeId = 4;

  @override
  ShopSettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopSettingsModel(
      shopName: fields[0] as String,
      address: fields[1] as String,
      phone: fields[2] as String,
      email: fields[3] as String,
      logoPath: fields[4] as String?,
      receiptCounter: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShopSettingsModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.shopName)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.logoPath)
      ..writeByte(5)
      ..write(obj.receiptCounter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopSettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
