class PaypalSettingData {
  bool isEnabled;
  bool isLive;
  String paypalSecret;
  String paypalClient;
  String paypalAppId;

  PaypalSettingData(
      {required this.isLive,
      required this.isEnabled,
      required this.paypalSecret,
      required this.paypalClient,
      this.paypalAppId = ''});

  factory PaypalSettingData.fromJson(Map<String, dynamic> parsedJson) {
    return PaypalSettingData(
      paypalSecret: parsedJson['paypalSecret'] ?? '',
      paypalClient: parsedJson['paypalClient'] ?? '',
      paypalAppId: parsedJson['paypalAppId'] ?? '',
      isLive: parsedJson['isLive'],
      isEnabled: parsedJson['isEnabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isLive': isLive,
      'paypalSecret': paypalSecret,
      'paypalClient': paypalClient,
      'paypalAppId': paypalAppId
    };
  }
}
