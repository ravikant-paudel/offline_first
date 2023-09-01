import 'package:offline_first/base_model.dart';

class OfflineModel extends BaseModel {
  String? name;
  int? age;

  OfflineModel({required this.name, required this.age});

  OfflineModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = this.name;
    data['age'] = this.age;
    return data;
  }

  @override
  String? get primaryKey => null;
}
