import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class VerifyOtpScreen extends StatefulWidget {
  String? otp;

  VerifyOtpScreen({Key? key, required this.otp}) : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String otp = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          Text("Collect OTP from customer".tr(), style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 18, fontWeight: FontWeight.w800)),
          SizedBox(
            height: 20,
          ),
          OtpTextField(
            numberOfFields: 6,
            borderColor: Color(COLOR_PRIMARY),
            //set to true to show as box or false to show as dash
            showFieldAsBox: false,
            //runs when a code is typed in
            onSubmit: (String verificationCode) {
              setState(() {
                otp = verificationCode;
              });
            }, // end onSubmit
            //runs when every textfield is filled
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(COLOR_PRIMARY),
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(
                      color: Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
                child: Text(
                  "Verify OTP".tr(),
                  style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () async {
                  await showProgress(context, 'OTP verify'.tr(), false);
                  try {
                    hideProgress();
                    if (otp == widget.otp) {
                      Navigator.pop(context, true);
                    } else {
                      showAlertDialog(context, 'Failed'.tr(), "OTP Invalid", true);
                    }
                    // Navigator.pop(context, true);
                  } catch (e) {
                    showAlertDialog(context, 'Failed'.tr(), e.toString(), true);
                  }
                  print(otp);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
