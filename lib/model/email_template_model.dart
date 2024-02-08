
class EmailTemplateModel {
  String? id;
  String? type;
  String? message;
  String? subject;
  bool? isSendToAdmin;


  EmailTemplateModel(
      { this.subject, this.id, this.type, this.message,this.isSendToAdmin});

  EmailTemplateModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    id = json['id'];
    type = json['type'];
    message = json['message'];
    isSendToAdmin = json['isSendToAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['id'] = this.id;
    data['type'] = this.type;
    data['message'] = this.message;
    data['isSendToAdmin'] = this.isSendToAdmin;
    return data;
  }
}
