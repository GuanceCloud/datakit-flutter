import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ft_mobile_agent_flutter/ft_rum.dart';

T? _ambiguate<T>(T? value) => value;

class FTRUMLongTaskObserver with WidgetsBindingObserver {
  /// The amount of elapsed time that is considered a long task, in seconds.
  final double longTaskThreshold;
  final FTRUMManager rumInstance;

  var _detectingLongTasks = false;
  Future<void>? _longTaskDetectorFuture;

  FTRUMLongTaskObserver({
    this.longTaskThreshold = 0.1,
    FTRUMManager? rumInstance,
  }) : rumInstance = rumInstance ?? FTRUMManager();

  void init() {
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    _startLongTaskDetection();
  }

  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    stopLongTaskDetection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _startLongTaskDetection();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      default:
        stopLongTaskDetection();
        break;
    }
  }

  void _startLongTaskDetection() async {
    if (_detectingLongTasks) {
      return;
    }
    if (_longTaskDetectorFuture != null) {
      await _longTaskDetectorFuture;
    }
    _detectingLongTasks = true;
    _longTaskDetectorFuture = _longTaskDetector();
  }

  @visibleForTesting
  Future<void> stopLongTaskDetection() async {
    if (_detectingLongTasks) {
      _detectingLongTasks = false;
      await _longTaskDetectorFuture;
      _longTaskDetectorFuture = null;
    }
  }

  Future<void> _longTaskDetector() async {
    final millisecondThreshold = longTaskThreshold * 1000;
    var lastCheck = DateTime.now().millisecondsSinceEpoch;
    while (_detectingLongTasks) {
      await Future<void>.delayed(const Duration(milliseconds: 13));
      final check = DateTime.now().millisecondsSinceEpoch;
      final taskLength = check - lastCheck;
      if (_detectingLongTasks && taskLength > millisecondThreshold) {
        await rumInstance.reportLongTask(taskLength);
      }
      lastCheck = check;
    }
  }
}
