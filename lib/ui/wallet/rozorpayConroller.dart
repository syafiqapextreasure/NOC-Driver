import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:nocdriver/constants.dart';
import 'package:nocdriver/model/createRazorPayOrderModel.dart';
import 'package:nocdriver/model/razorpayKeyModel.dart';
import 'package:nocdriver/userPrefrence.dart';
import 'package:http/http.dart' as http;

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount}) async {
    final String orderId = DateTime.now().toIso8601String();
    RazorPayModel razorPayData = UserPreference.getRazorPayData();

    Map<String, String> header = {
      HttpHeaders.acceptHeader: 'application/json;charset=UTF-8',
      HttpHeaders.connectionHeader: 'keep-alive',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Map<String, String> body = {
      "amount": '1',
      "receipt_id": '1',
      "currency": '1',
      "razorpaykey": '1',
      "razorPaySecret": '1',
      "isSandBoxEnabled": '1',
    };

    final response = await http.post(
      Uri.parse("${GlobalURL}payments/razorpay/createorder"),
      headers: header,
      body: jsonEncode(body),
    );
    log(jsonEncode(body));
    log(response.statusCode.toString());
    log(response.body.toString());
    log(response.request.toString());
    log(jsonEncode(response.headers));
    log("----->");
    if (response.statusCode == 500) {
      return null;
    } else {
      // final data = jsonDecode(response.body);
      //
      // return CreateRazorPayOrderModel.fromJson(data);
    }
  }
}
