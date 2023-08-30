abstract class BaseModel {
  String? get primaryKey;

  Map<String, dynamic> toJson();
}
