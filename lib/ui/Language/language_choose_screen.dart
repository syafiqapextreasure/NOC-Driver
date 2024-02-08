import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:nocdriver/services/FirebaseHelper.dart';
import 'package:nocdriver/services/helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_model.dart';

class LanguageChooseScreen extends StatefulWidget {
  bool isContainer = false;

  LanguageChooseScreen({Key? key, required this.isContainer}) : super(key: key);

  @override
  State<LanguageChooseScreen> createState() => _LanguageChooceScreenState();
}

class _LanguageChooceScreenState extends State<LanguageChooseScreen> {
  var languageList = <LanguageModel>[];
  String selectedLanguage = "en";

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    languageList.clear();
    await FireStoreUtils.firestore.collection(Setting).doc("languages").get().then((value) {
      List list = value.data()!["list"];
      for (int i = 0; i < list.length; i++) {
        if (list[i]['isActive'] == true) {
          LanguageModel languageModel = LanguageModel.fromJson(list[i]);
          languageList.add(languageModel);
        }
      }
    });
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.containsKey("languageCode")) {
      selectedLanguage = sp.getString("languageCode")!;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            itemCount: languageList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedLanguage = languageList[index].slug.toString();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    decoration: languageList[index].slug == selectedLanguage
                        ? BoxDecoration(
                            border: Border.all(color: Color(COLOR_PRIMARY)),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                ),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          languageList[index].flag != null
                              ? Image.network(
                                  languageList[index].flag.toString(),
                                  height: 60,
                                  width: 60,
                                )
                              : CachedNetworkImage(
                                  imageUrl: placeholderImage,
                                  height: 60,
                                  width: 60,
                                ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(languageList[index].title.toString(), style: const TextStyle(fontFamily: "GlacialIndifference",fontSize: 16)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(COLOR_PRIMARY),
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
            ),
            onPressed: () async {
              SharedPreferences sp = await SharedPreferences.getInstance();
              sp.setString("languageCode", selectedLanguage);
              context.setLocale(Locale(selectedLanguage));

              if (widget.isContainer) {
                SnackBar snack = SnackBar(
                  content: const Text(
                    'Language change successfully',
                    style: TextStyle(fontFamily: "GlacialIndifference",color: Colors.white),
                  ).tr(),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.black,
                );
                ScaffoldMessenger.of(context).showSnackBar(snack);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save'.tr(),
              style: TextStyle(fontFamily: "GlacialIndifference",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
                // isDarkMode(context) ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
