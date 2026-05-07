import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../ft_session_replay.dart';
import 'capture/recorder.dart';
import 'processor/processor.dart';
import 'rum_context.dart';
import 'session_replay_internal.dart';
import 'session_replay_platform.dart';

class FTSessionReplay {
  static const minCaptureTiming = Duration(milliseconds: 100);
  static const errorTolerance = 10;

  static FTSessionReplay? _instance;
  static FTSessionReplay? get instance => _instance;

  @visibleForTesting
  static void resetForTesting() {
    _instance?._stop();
    _instance = null;
  }

  final FTSessionReplayConfig _configuration;
  @internal
  final FTSessionReplayLogger internalLogger;

  final SessionReplayProcessor _processor = SessionReplayProcessor();
  final SessionReplayRecorder _recorder;

  final TouchPrivacyLevel defaultTouchPrivacyLevel;

  int _errorCounter = 0;
  bool _newFrameBuilt = true;
  Timer? _captureTimer;

  @internal
  static Future<FTSessionReplay> init(
    FTSessionReplayConfig configuration, {
    FTSessionReplayLogger logger = const FTSessionReplayLogger(),
  }) async {
    _instance?._stop();
    final replay = FTSessionReplay._(configuration, logger);
    _instance = replay;
    await replay._start();
    return replay;
  }

  FTSessionReplay._(this._configuration, this.internalLogger)
      : defaultTouchPrivacyLevel = _configuration.touchPrivacy,
        _recorder = SessionReplayRecorder(
          defaultCapturePrivacy: TreeCapturePrivacy(
            textAndInputPrivacyLevel: _configuration.textAndInputPrivacy,
            imagePrivacyLevel: _configuration.imagePrivacy,
          ),
          touchPrivacyLevel: _configuration.touchPrivacy,
        );

  void addElement(Key key, Element element) {
    _recorder.addElement(key, element);
  }

  void removeElement(Key key) {
    _recorder.removeElement(key);
  }

  void _onContextChanged(RUMContext context) {
    _recorder.onContextChanged(context);
  }

  void _stop() {
    _captureTimer?.cancel();
    _captureTimer = null;
    _processor.stop();
  }

  Future<void> _start() async {
    final platform = FTSessionReplayPlatform.instance;
    var success = false;
    await wrapAsync('enable', internalLogger, <String, Object?>{}, () async {
      success =
          await platform.enable(_configuration.toMap(), _onContextChanged);
    });

    if (!success) return;

    await _processor.start();
    _startPeriodicCapture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _newFrameBuilt = true;
    });
  }

  void _startPeriodicCapture() {
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(minCaptureTiming, (timer) async {
      var shouldWatchForNextFrame = true;
      if (_newFrameBuilt) {
        try {
          final context =
              await FTSessionReplayPlatform.instance.getCurrentContext();
          if (context != null) _onContextChanged(context);

          final captureResult = await _recorder.performCapture();
          if (captureResult != null) {
            _processor.process(captureResult);
          }
          _errorCounter = max(0, _errorCounter - 1);
        } catch (e, st) {
          internalLogger.sendToDatadog(
            'Exception during session replay capture: $e',
            st,
            e.runtimeType.toString(),
          );
          internalLogger.log(
            CoreLoggerLevel.warn,
            'Exception during session replay capture: $e',
          );
          _errorCounter += 1;
          if (_errorCounter > errorTolerance) {
            internalLogger.sendToDatadog(
              'Flutter Session Replay exceeded its error tolerance of $errorTolerance. Shutting down.',
              null,
              null,
            );
            timer.cancel();
            shouldWatchForNextFrame = false;
          }
        }
        _newFrameBuilt = false;
      }

      if (shouldWatchForNextFrame) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _newFrameBuilt = true;
        });
      }
    });
  }
}
