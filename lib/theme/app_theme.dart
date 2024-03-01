import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData get theme {
    return ThemeData.light().copyWith(
      primaryColor: Colors.deepPurple,
      hintColor: Colors.amber,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.amber,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
        bodyLarge: TextStyle(
          fontSize: 14.0,
          color: Colors.deepPurple.shade600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.deepPurple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
        labelStyle: const TextStyle(color: Colors.deepPurple),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        titleTextStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16.0,
          color: Colors.deepPurple.shade800,
        ),
      ),
    );
  }
}
