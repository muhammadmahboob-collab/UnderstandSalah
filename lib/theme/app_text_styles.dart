import 'package:flutter/material.dart';

class AppTextStyles {
  static const String _arabicFontFamily = 'NotoNaskhArabic';

  static TextStyle arabicWord({double fontSize = 48, Color? color}) {
    return TextStyle(
      fontFamily: _arabicFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle arabicTitle({double fontSize = 28, Color? color}) {
    return TextStyle(
      fontFamily: _arabicFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
