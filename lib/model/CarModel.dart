class CarModel {
  String? name;
  String? carMakeName;
  String? id;
  bool? isActive;
  String? carMakeId;

  CarModel({this.name, this.carMakeName, this.id, this.isActive, this.carMakeId});

  CarModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    carMakeName = json['car_make_name'];
    id = json['id'];
    isActive = json['isActive'];
    carMakeId = json['car_make_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['car_make_name'] = this.carMakeName;
    data['id'] = this.id;
    data['isActive'] = this.isActive;
    data['car_make_id'] = this.carMakeId;
    return data;
  }
}
