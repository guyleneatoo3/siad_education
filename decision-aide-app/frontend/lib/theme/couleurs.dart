import 'package:flutter/material.dart';

class CouleursTheme {
  static const Color primaire = Color(0xFF2D6A4F);
  static const Color secondaire = Color(0xFF40916C);
  static const Color accent = Color(0xFF52B788);
}

ThemeData themeClair() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: CouleursTheme.primaire),
    useMaterial3: true,
  );
}
