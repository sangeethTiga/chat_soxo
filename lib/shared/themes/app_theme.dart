import 'package:flutter/material.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';

import '../constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    brightness: Brightness.light,
    scaffoldBackgroundColor: kWhite,
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryColor1,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: FontPalette.hW700S23.copyWith(color: kBlack),
      iconTheme: const IconThemeData(color: kPrimaryColor),
    ),
    canvasColor: kSecondaryColor1,

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kWhite,
      labelStyle: TextStyle(color: kBlack.withOpacity(0.8)),
      errorStyle: const TextStyle(color: kRedColor),
      errorMaxLines: 5,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          style: BorderStyle.solid,
          color: kSecondaryColor3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          style: BorderStyle.solid,
          color: kRedColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          style: BorderStyle.solid,
          color: kPrimaryColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          style: BorderStyle.solid,
          color: kPrimaryColor,
        ),
      ),
    ),
    textTheme: FontPalette.textLightTheme,
    primaryTextTheme: FontPalette.textLightTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(kPrimaryColor),
        foregroundColor: WidgetStateProperty.all<Color>(kWhite),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    ),
    fontFamily: FontPalette.themeFont,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kWhite,
    ),
  );
}
