import 'package:flutter/material.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  bool isAppInForeground = true;
  bool isAppClosed = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isAppInForeground = true;
      isAppClosed = false;
    } else if (state == AppLifecycleState.paused) {
      isAppInForeground = false;
      isAppClosed = false;
    } else if (state == AppLifecycleState.detached) {
      isAppClosed = true;
    }
  }
}

AppLifecycleObserver lifecycleObserver = AppLifecycleObserver();
