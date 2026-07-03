import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../ft_session_replay_flutter.dart';
import 'capture/recorder.dart';
import 'processor/processor.dart';
import 'rum_context.dart';
import 'session_replay_internal.dart';
import 'session_replay_platform.dart';

@internal
void resetSessionReplay() {
  FTSessionReplay._instance?._stop();
  FTSessionReplay._instance = null;
  FTSessionReplay._instanceNotifier.value = null;
}

class FTSessionReplay {
  static const minCaptureTiming = Duration(milliseconds: 100);
  static const errorTolerance = 10;

  static FTSessionReplay? _instance;
  static final ValueNotifier<FTSessionReplay?> _instanceNotifier =
      ValueNotifier<FTSessionReplay?>(null);
  static FTSessionReplay? get instance => _instance;

  @internal
  static ValueListenable<FTSessionReplay?> get instanceListenable =>
      _instanceNotifier;

  @visibleForTesting
  static void resetForTesting() {
    resetSessionReplay();
  }

  final FTSessionReplayConfig _configuration;
  @internal
  final FTSessionReplayLogger internalLogger;

  final SessionReplayProcessor _processor = SessionReplayProcessor();
  final SessionReplayRecorder _recorder;

  final TouchPrivacyLevel defaultTouchPrivacyLevel;

  int _errorCounter = 0;
  bool _newFrameBuilt = true;
  String? _lastHasReplayViewId;
  Timer? _captureTimer;

  @internal
  static Future<FTSessionReplay> init(
    FTSessionReplayConfig configuration, {
    FTSessionReplayLogger logger = const FTSessionReplayLogger(),
  }) async {
    _instance?._stop();
    final replay = FTSessionReplay._(configuration, logger);
    _instance = replay;
    _instanceNotifier.value = replay;
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

  Future<void> _onContextChanged(RUMContext? context) async {
    if (context == null) {
      _recorder.updateContext(null);
      _lastHasReplayViewId = null;
      return;
    }
    _recorder.onContextChanged(context);
    final viewId = context.viewId;
    if (viewId == null || viewId == _lastHasReplayViewId) return;
    try {
      await FTSessionReplayPlatform.instance.setHasReplay(viewId, true);
      _lastHasReplayViewId = viewId;
    } catch (e, st) {
      internalLogger.sendTelemetry(
        'Error setting Session Replay hasReplay: $e',
        st,
        e.runtimeType.toString(),
      );
    }
  }

  void _onSampleStateChanged(FTSessionReplaySampleState state) {
    _processor.setSampledForErrorReplay(state.sampledForErrorReplay);
    if (!state.sampled) {
      _recorder.updateContext(null);
      _lastHasReplayViewId = null;
      _processor.reset();
    }
    _newFrameBuilt = true;
  }

  void _stop() {
    FTSessionReplayPlatform.instance.setSampleStateChangedHandler(null);
    _captureTimer?.cancel();
    _captureTimer = null;
    _processor.stop();
  }

  Future<void> _start() async {
    final platform = FTSessionReplayPlatform.instance;
    var success = false;
    platform.setSampleStateChangedHandler(_onSampleStateChanged);
    try {
      await wrapAsync('enable', internalLogger, <String, Object?>{}, () async {
        success = await platform.enable(_configuration.toMap(), (context) {
          unawaited(_onContextChanged(context));
        });
      });
    } catch (_) {
      platform.setSampleStateChangedHandler(null);
      rethrow;
    }

    if (!success) {
      platform.setSampleStateChangedHandler(null);
      return;
    }

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
          final platform = FTSessionReplayPlatform.instance;
          if (!platform.sessionReplaySampled) {
            await _onContextChanged(null);
            _processor.reset();
          } else {
            final context = await platform.getCurrentContext();
            if (context == null) {
              await _onContextChanged(null);
              _processor.reset();
            } else {
              _processor.setSampledForErrorReplay(
                platform.sessionReplaySampledForErrorReplay,
              );
              await _onContextChanged(context);
              final captureResult = await _recorder.performCapture();
              if (captureResult != null) {
                _processor.process(captureResult);
              }
            }
          }
          _errorCounter = max(0, _errorCounter - 1);
        } catch (e, st) {
          internalLogger.sendTelemetry(
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
            internalLogger.sendTelemetry(
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
