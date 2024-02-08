import 'package:flutter/material.dart';

import '../constants.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primaryColor: isDarkTheme ? const Color(0xff131218) : Color(COLOR_PRIMARY),
      indicatorColor: isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
      hintColor: isDarkTheme ? Colors.white38 : Colors.black38,
      highlightColor: isDarkTheme ? Colors.white38 : Colors.black38,
      disabledColor: Colors.grey,
      backgroundColor: isDarkTheme ? const Color(0xff131218) : const Color(0xffF1F5FB),
      iconTheme: IconThemeData(color: isDarkTheme ? Colors.white : Colors.black),
      cardColor: isDarkTheme ? const Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      bottomSheetTheme: isDarkTheme ? BottomSheetThemeData(backgroundColor: Colors.grey.shade900) : const BottomSheetThemeData(backgroundColor: Colors.white),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(colorScheme: isDarkTheme ? const ColorScheme.dark() : const ColorScheme.light()),
      appBarTheme: isDarkTheme
          ? AppBarTheme(backgroundColor: const Color(0xff131218), centerTitle: true, iconTheme: IconThemeData(color: Colors.white), elevation: 0)
          : AppBarTheme(titleTextStyle: TextStyle(fontFamily : "GlacialIndifference",color: Color(COLOR_PRIMARY)), backgroundColor: Colors.white, centerTitle: true, iconTheme: IconThemeData(color: Colors.black), elevation: 0),
      textSelectionTheme: TextSelectionThemeData(selectionColor: isDarkTheme ? Colors.yellow : Colors.black),
    );
  }
}
