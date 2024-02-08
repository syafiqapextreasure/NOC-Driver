
class NotificationModel {
  String? subject;
  String? id;
  String? type;
  String? message;

  NotificationModel(
      { this.subject, this.id, this.type, this.message});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    id = json['id'];
    type = json['type'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['id'] = this.id;
    data['type'] = this.type;
    data['message'] = this.message;
    return data;
  }
}
