import 'dart:developer';

abstract class Logger {
  static void printRed(String? message) => _print(message, 31);

  static void printGreen(String? message) => _print(message, 32);

  static void printYellow(String? message) => _print(message, 33);

  static void printBlue(String? message) => _print(message, 34);

  static void printMagenta(String? message) => _print(message, 35);

  static void printCyan(String? message) => _print(message, 36);

  static void _print(String? message, int colorCode) {
    log('--> \x1b[${colorCode}m$message\x1b[0m');
  }
}
