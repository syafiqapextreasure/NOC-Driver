class SectionModel {
  String? referralAmount;
  String? serviceType;
  String? taxAmount;
  String? color;
  String? taxType;
  String? name;
  String? taxLable;
  String? sectionImage;
  String? id;
  bool? taxActive;
  bool? isActive;
  bool? dineInActive;
  String? serviceTypeFlag;
  String? commissionAmount;
  String? commissionType;
  bool? isEnableCommission;

  SectionModel(
      {this.serviceType,
        this.referralAmount,
      this.taxAmount,
      this.color,
      this.taxType,
      this.name,
      this.taxLable,
      this.sectionImage,
      this.id,
      this.taxActive,
      this.isActive,
      this.commissionAmount,
      this.commissionType,
      this.isEnableCommission,
      this.dineInActive,
      this.serviceTypeFlag});

  SectionModel.fromJson(Map<String, dynamic> json) {
    serviceType = json['serviceType'] ?? '';
    referralAmount = json['referralAmount'] ?? '';
    taxAmount = json['tax_amount'];
    color = json['color'];
    taxType = json['tax_type'];
    name = json['name'];
    taxLable = json['tax_lable'];
    sectionImage = json['sectionImage'];
    id = json['id'];
    taxActive = json['tax_active'];
    commissionAmount = json['commissionAmount'].toString();
    commissionType = json['commissionType'] ?? '';
    isEnableCommission = json['isEnableCommission'] ?? false;
    isActive = json['isActive'];
    dineInActive = json['dine_in_active'] ?? false;
    serviceTypeFlag = json['serviceTypeFlag'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['serviceType'] = serviceType;
    data['referralAmount'] = referralAmount;
    data['tax_amount'] = taxAmount;
    data['color'] = color;
    data['tax_type'] = taxType;
    data['name'] = name;
    data['tax_lable'] = taxLable;
    data['sectionImage'] = sectionImage;
    data['commissionAmount'] = commissionAmount;
    data['commissionType'] = commissionType;
    data['isEnableCommission'] = isEnableCommission;
    data['id'] = id;
    data['tax_active'] = taxActive;
    data['isActive'] = isActive;
    data['dine_in_active'] = dineInActive;
    data['serviceTypeFlag'] = serviceTypeFlag;
    return data;
  }
}
