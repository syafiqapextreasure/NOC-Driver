class MailSettings {
  String? emailSetting;
  String? fromName;
  String? host;
  String? mailEncryptionType;
  String? mailMethod;
  String? password;
  String? port;
  String? userName;

  MailSettings(
      {this.emailSetting,
        this.fromName,
        this.host,
        this.mailEncryptionType,
        this.mailMethod,
        this.password,
        this.port,
        this.userName});

  MailSettings.fromJson(Map<String, dynamic> json) {
    emailSetting = json['emailSetting'];
    fromName = json['fromName'];
    host = json['host'];
    mailEncryptionType = json['mailEncryptionType'];
    mailMethod = json['mailMethod'];
    password = json['password'];
    port = json['port'];
    userName = json['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emailSetting'] = this.emailSetting;
    data['fromName'] = this.fromName;
    data['host'] = this.host;
    data['mailEncryptionType'] = this.mailEncryptionType;
    data['mailMethod'] = this.mailMethod;
    data['password'] = this.password;
    data['port'] = this.port;
    data['userName'] = this.userName;
    return data;
  }
}
