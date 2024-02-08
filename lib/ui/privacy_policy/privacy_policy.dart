import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nocdriver/services/helper.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? termsAndCondition;

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection(Setting)
        .doc("privacyPolicy")
        .get()
        .then((value) {
      print(value['privacy_policy']);
      if (value != null) {
        setState(() {
          termsAndCondition = value['privacy_policy'];
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy policy',
          style: TextStyle(
            fontFamily: "GlacialIndifference",
            color: Colors.black,
          ),
        ).tr(),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Color(0xfffffc05),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: termsAndCondition != null
              ? HtmlWidget(
                  // the first parameter (`html`) is required
                  '''
                  $termsAndCondition
                   ''',
                  customStylesBuilder: (element) {
                    if (element.localName == 'font') {
                      return {
                        'color': isDarkMode(context)
                            ? '#fff !important'
                            : '#000 !important'
                      };
                    }
                    if (element.localName == 'span') {
                      return {
                        'color': isDarkMode(context)
                            ? '#fff !important'
                            : '#000 !important'
                      };
                    }
                    if (element.localName == 'p') {
                      return {
                        'color': isDarkMode(context)
                            ? '#fff !important'
                            : '#000 !important'
                      };
                    }
                    return null;
                  },
                  onErrorBuilder: (context, element, error) =>
                      Text('$element ${"error: ".tr()}$error'),
                  onLoadingBuilder: (context, element, loadingProgress) =>
                      const CircularProgressIndicator(),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
