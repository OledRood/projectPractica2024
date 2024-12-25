import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const pinkTheme = ColorPalette(
    color900: Color(0xff94003d),
    color800: Color(0xFFb60040),
    color700: Color(0xFFc90042),
    color600: Color(0xFFde0044),
    color500: Color(0xFFee0245),
    color400: Color(0xFFf3345f),
    color300: Color(0xfff85b7b),
    color200: Color(0xFFfeb9c6),
    color100: Color(0xFFfeb9c6),
    color50: Color(0xFFffe3e8),
    colorText: Colors.black,
    colorSelectedText: Colors.white,
  );

  static const darkTheme = ColorPalette(
    color900: Color(0xFFffe7eb),
    color800: Color(0xFFfcd0da),
    color700: Color(0xFFf2a6c6),
    color600: Color(0xffe65a7b),
    color500: Color(0xFFd83565),
    color400: Color(0xFFc80045),
    color300: Color(0xFFa60038),
    color200: Color(0xFF900032),
    color100: Color(0xFF73002a),
    color50: Color(0xff4a001e),
    colorText: Color(0xFFfcd0da),
    colorSelectedText: Colors.grey,
  );

  static const greenTheme = ColorPalette(
    color900: Color(0xFF006B00),
    color800: Color(0xFF008D00),
    color700: Color(0xFF00A20A),
    color600: Color(0xFF1BB618),
    color500: Color(0xFF33C620),
    color400: Color(0xFF5ECF4A),
    color300: Color(0xFF80D86D),
    color200: Color(0xFFA7E399),
    color100: Color(0xFFCBFEC1),
    color50: Color(0xFFEAF9E6),
    colorText: Colors.black,
    colorSelectedText: Colors.white,
  );
  static const yellowTheme = ColorPalette(
    color900: Color(0xFFFF8000),
    color800: Color(0xFFFF9900),
    color700: Color(0xFFFFA600),
    color600: Color(0xFFFFB400),
    color500: Color(0xFFFFC200),
    color400: Color(0xFFFFD000),
    color300: Color(0xFFFFD633),
    color200: Color(0xFFFFDD66),
    color100: Color(0xFFFFE999),
    color50: Color(0xFFFFF4CC),
    colorText: Colors.black,
    colorSelectedText: Colors.white,
  );
  static const brownTheme = ColorPalette(
    color900: Color(0xFF4B0B05),
    color800: Color(0xFF5B1B12),
    color700: Color(0xFF6A2817),
    color600: Color(0xFF7A341F),
    color500: Color(0xFF863D25),
    color400: Color(0xFF9F5840),
    color300: Color(0xFFB7735B),
    color200: Color(0xFFD99782),
    color100: Color(0xFFF9BCA6),
    color50: Color(0xFFFFDFC5),
    colorText: Colors.black,
    colorSelectedText: Colors.white,
  );
  static const blueTheme = ColorPalette(
    color900: Color(0xFF101996),
    color800: Color(0xFF232EA9),
    color700: Color(0xFF2C39B5),
    color600: Color(0xFF3644C1),
    color500: Color(0xFF3B4CCB),
    color400: Color(0xFF5A68D4),
    color300: Color(0xFF7984DC),
    color200: Color(0xFFA0A7E6),
    color100: Color(0xFFC6C9F0),
    color50: Color(0xFFE8EAF9),
    colorText: Colors.black,
    colorSelectedText: Colors.white,
  );
}

class ColorPalette {
  final Color color900;
  final Color color800;
  final Color color700;
  final Color color600;
  final Color color500;
  final Color color400;
  final Color color300;
  final Color color200;
  final Color color100;
  final Color color50;
  final Color colorText;
  final Color colorSelectedText;

  const ColorPalette({
    required this.color900,
    required this.color800,
    required this.color700,
    required this.color600,
    required this.color500,
    required this.color400,
    required this.color300,
    required this.color200,
    required this.color100,
    required this.color50,
    required this.colorText,
    required this.colorSelectedText,
  });
}
