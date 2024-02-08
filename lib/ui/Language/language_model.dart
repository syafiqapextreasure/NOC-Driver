class LanguageModel {
  bool? isRtl;
  String? title;
  bool? isActive;
  String? slug;
  String? flag;

  LanguageModel({this.isRtl, this.title, this.isActive, this.slug, this.flag});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    isRtl = json['is_rtl'];
    title = json['title'];
    isActive = json['isActive'];
    slug = json['slug'];
    flag = json['flag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_rtl'] = isRtl;
    data['title'] = title;
    data['isActive'] = isActive;
    data['slug'] = slug;
    data['flag'] = flag;
    return data;
  }
}
