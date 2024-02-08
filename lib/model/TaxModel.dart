class TaxModel {
  String? country;
  bool? enable;
  String? tax;
  String? id;
  String? type;
  String? title;

  TaxModel({this.country, this.enable, this.tax, this.id, this.type, this.title});

  TaxModel.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    enable = json['enable'];
    tax = json['tax'];
    id = json['id'];
    type = json['type'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['enable'] = enable;
    data['tax'] = tax;
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    return data;
  }
}
