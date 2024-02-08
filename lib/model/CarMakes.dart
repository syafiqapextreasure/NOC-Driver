class CarMakes {
  String? name;
  String? id;
  bool? isActive;

  CarMakes({this.name, this.id, this.isActive});

  CarMakes.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    id = json['id'] ?? '';
    isActive = json['isActive'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    data['isActive'] = this.isActive;
    return data;
  }
}
