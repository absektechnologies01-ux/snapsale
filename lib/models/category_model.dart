import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? iconEmoji;

  @HiveField(3)
  DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconEmoji,
    required this.createdAt,
  });

  CategoryModel copyWith({String? name, String? iconEmoji}) => CategoryModel(
        id: id,
        name: name ?? this.name,
        iconEmoji: iconEmoji ?? this.iconEmoji,
        createdAt: createdAt,
      );
}
