import 'package:flutter/material.dart';

class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {Color color = Colors.red}) {
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
