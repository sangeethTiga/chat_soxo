import 'package:flutter/material.dart';

import '../constants/colors.dart';

class FontPalette {
  static const themeFont = "Manrope";

  static TextTheme get textLightTheme {
    return Typography.englishLike2018.apply(
      fontSizeFactor: 0.8,
      bodyColor: kBlack,
      fontFamily: FontPalette.themeFont,
    );
  }

  // Add fontFamily to ALL TextStyles
  static TextStyle hW700S23 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: kBlack,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: kBlack,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW800S26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    color: kBlack,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: kBlack,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,

    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S16CGrey = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: Color(0xff666C6D),
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: kBlack,

    fontFamily: themeFont, // Added this
  );

  static TextStyle hW600S14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW600S20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW600S12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW600S13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S9 = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW600S11 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW800S16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW800S20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S11 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW500S16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S10 = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW400S8 = TextStyle(
    fontSize: 8, // Fixed this - was 10
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S11 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );

  static TextStyle hW700S26 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    fontFamily: themeFont, // Added this
  );
}
