

// 1. Declare the generic type <T> on the StatefulWidget
import 'package:flutter/material.dart';

abstract class AppStateWidget<T extends StatefulWidget> extends State<T> {
  // Your common logic (e.g., showLoading, common error handling) goes here

  // Example: a helper that can be used across all edit widgets
  void showSnackBar({required String content, Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(content), backgroundColor: backgroundColor ?? Colors.green),
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force a UI refresh when the app and OS wake up
      setState(() {});
    }
  }

}