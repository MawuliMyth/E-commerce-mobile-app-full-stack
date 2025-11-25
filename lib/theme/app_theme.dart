import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    hintColor: Colors.black,
    // cardColor: Colors.grey[100],
    scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    hintColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );
}
