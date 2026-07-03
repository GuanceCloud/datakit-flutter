// Unless explicitly stated otherwise all files copied from Datadog are licensed under the Apache License Version 2.0.

import 'package:flutter/widgets.dart';

import '../capture/recorder.dart';
import 'processor_worker.dart';

/// Processes captured Session Replay snapshots and writes encoded segments to
/// the native FT SDK upload pipeline.
class SessionReplayProcessor with WidgetsBindingObserver {
  final ProcessorWorker _worker = ProcessorWorker();
  bool _isProcessing = false;

  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  void reset() {
    _worker.reset();
  }

  void setSampledForErrorReplay(bool sampledForErrorReplay) {
    _worker.setSampledForErrorReplay(sampledForErrorReplay);
  }

  void process(CaptureResult captureResult) {
    if (_isProcessing) return;
    _isProcessing = true;
    _worker.processSnapshot(captureResult).whenComplete(() {
      _isProcessing = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }
}
