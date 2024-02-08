import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/main.dart';
import 'package:nocdriver/model/User.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';

class EnterBankDetailScreen extends StatefulWidget {
  final bool isNewAccount;
  const EnterBankDetailScreen({Key? key, required this.isNewAccount}) : super(key: key);

  @override
  State<EnterBankDetailScreen> createState() => _EnterBankDetailScreenState();
}

class _EnterBankDetailScreenState extends State<EnterBankDetailScreen> {
  User? user;

  GlobalKey<FormState> _bankDetailFormKey = GlobalKey();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController branchNameController = TextEditingController();
  TextEditingController holderNameController = TextEditingController();
  TextEditingController accountNoController = TextEditingController();
  TextEditingController otherInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    FireStoreUtils.getCurrentUser(MyAppState.currentUser!.userID).then((value) {
      setState(() {
        user = value!;
        MyAppState.currentUser = value;

        bankNameController = TextEditingController(text: user!.userBankDetails.bankName);
        branchNameController = TextEditingController(text: user!.userBankDetails.branchName);
        holderNameController = TextEditingController(text: user!.userBankDetails.holderName);
        accountNoController = TextEditingController(text: user!.userBankDetails.accountNumber);
        otherInfoController = TextEditingController(text: user!.userBankDetails.otherDetails);
      });
    });
    //user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
          ),
        ),
        title: Text(
          widget.isNewAccount ? "Add Bank".tr() : "Edit Bank".tr(),
          style: TextStyle(fontFamily: "GlacialIndifference",
              color: isDarkMode(context) ? Colors.white : Color(DARK_COLOR)),
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Form(
          key: _bankDetailFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                buildTextFiled(validator: validateName, title: "Bank Name".tr(), controller: bankNameController),
                buildTextFiled(validator: validateOthers, title: "Branch Name".tr(), controller: branchNameController),
                buildTextFiled(validator: validateOthers, title: "Holder Name".tr(), controller: holderNameController),
                buildTextFiled(validator: validateOthers, title: "Account Number".tr(), controller: accountNoController),
                buildTextFiled(
                    validator: (String? value) {
                      return null;
                    },
                    title: "Other Information".tr(),
                    controller: otherInfoController),
                Padding(
                  padding: const EdgeInsets.only(top: 45.0, bottom: 25),
                  child: buildButton(context, title: widget.isNewAccount ? "Add Bank".tr() : "Edit Bank".tr(), onPress: () async {
                    if (_bankDetailFormKey.currentState!.validate()) {
                      print("----<");
                      user!.userBankDetails.accountNumber = accountNoController.text;
                      print("----<");
                      print(user!.userBankDetails.accountNumber);
                      user!.userBankDetails.bankName = bankNameController.text;
                      user!.userBankDetails.branchName = branchNameController.text;
                      user!.userBankDetails.holderName = holderNameController.text;
                      user!.userBankDetails.otherDetails = otherInfoController.text;

                      var updatedUser = await FireStoreUtils.updateCurrentUser(user!);
                      if (updatedUser != null) {
                        MyAppState.currentUser = updatedUser;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Bank Details saved successfully',
                          style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 17),
                        ).tr()));
                        Navigator.pop(context, true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          "Couldn't save details, Please try again.",
                          style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 17),
                        ).tr()));
                        Navigator.pop(context, false);
                      }
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFiled({required title, required String? Function(String?)? validator, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              style: TextStyle(fontFamily: "GlacialIndifference",color: isDarkMode(context) ? Colors.white : Color(DARK_COLOR)),
              cursorColor: Color(COLOR_PRIMARY),
              textAlignVertical: TextAlignVertical.center,
              validator: validator,
              controller: controller,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: new EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                fillColor: isDarkMode(context) ? Colors.white.withOpacity(0.3) : Color(DARK_COLOR).withOpacity(0.06),
                filled: true,
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 1.50)),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).errorColor),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildButton(context, {required String title, required Function()? onPress}) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.8,
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        color: Colors.yellow,
        height: 45,
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 19, color: Colors.black),
        ),
      ),
    );
  }
}
