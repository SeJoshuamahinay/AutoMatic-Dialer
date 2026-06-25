import 'package:flutter/material.dart';

class AppLifecycleGuard with WidgetsBindingObserver {
  AppLifecycleGuard._();

  static final AppLifecycleGuard instance = AppLifecycleGuard._();

  AppLifecycleState? _state;

  AppLifecycleState? get state => _state;

  bool get isInBackground =>
      _state == AppLifecycleState.paused ||
      _state == AppLifecycleState.inactive;

  final List<VoidCallback> _pauseCallbacks = [];
  final List<VoidCallback> _resumeCallbacks = [];

  void register(void Function()? onPause, void Function()? onResume) {
    if (onPause != null) _pauseCallbacks.add(onPause);
    if (onResume != null) _resumeCallbacks.add(onResume);
  }

  void unregister(void Function()? onPause, void Function()? onResume) {
    if (onPause != null) _pauseCallbacks.remove(onPause);
    if (onResume != null) _resumeCallbacks.remove(onResume);
  }

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _state = state;

    if (state == AppLifecycleState.paused) {
      for (final cb in _pauseCallbacks) {
        cb();
      }
    }

    if (state == AppLifecycleState.resumed) {
      for (final cb in _resumeCallbacks) {
        cb();
      }
    }
  }
}
