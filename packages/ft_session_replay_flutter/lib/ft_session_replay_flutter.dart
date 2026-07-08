import 'package:meta/meta.dart';

import 'src/ft_session_replay.dart';

export 'src/ft_session_replay.dart' show FTSessionReplay;
export 'src/widgets.dart' show SessionReplayCapture, SessionReplayPrivacy;

typedef TouchPrivacyLevel = FTTouchPrivacyLevel;
typedef TextAndInputPrivacyLevel = FTTextAndInputPrivacyLevel;
typedef ImagePrivacyLevel = FTImagePrivacyLevel;

class FTSessionReplayConfig {
  FTSessionReplayConfig({
    this.sampleRate,
    this.sessionReplayOnErrorSampleRate,
    this.touchPrivacy = FTTouchPrivacyLevel.hide,
    this.textAndInputPrivacy = FTTextAndInputPrivacyLevel.maskAll,
    this.imagePrivacy = FTImagePrivacyLevel.maskAll,
    this.enableLinkRUMKeys,
    this.enableSwiftUI = false,
  })  : assert(sampleRate == null || (sampleRate >= 0 && sampleRate <= 1)),
        assert(sessionReplayOnErrorSampleRate == null ||
            (sessionReplayOnErrorSampleRate >= 0 &&
                sessionReplayOnErrorSampleRate <= 1));

  /// Sampling rate in range [0, 1]. Defaults to 1.0.
  final double? sampleRate;

  /// Error-session replay sampling rate in range [0, 1]. Defaults to 0.0.
  final double? sessionReplayOnErrorSampleRate;

  final FTTouchPrivacyLevel touchPrivacy;
  final FTTextAndInputPrivacyLevel textAndInputPrivacy;
  final FTImagePrivacyLevel imagePrivacy;

  /// Additional RUM keys attached to replay records.
  final List<String>? enableLinkRUMKeys;

  /// iOS only. Enable native SwiftUI recording in Session Replay.
  final bool enableSwiftUI;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sampleRate': sampleRate,
      'sessionReplayOnErrorSampleRate': sessionReplayOnErrorSampleRate,
      'touchPrivacy': touchPrivacy.index,
      'textAndInputPrivacy': textAndInputPrivacy.index,
      'imagePrivacy': imagePrivacy.index,
      'enableLinkRUMKeys': enableLinkRUMKeys,
      'enableSwiftUI': enableSwiftUI,
    };
  }
}

enum FTTouchPrivacyLevel {
  show,
  hide,
}

enum FTTextAndInputPrivacyLevel {
  maskSensitiveInputs,
  maskAllInputs,
  maskAll,
}

enum FTImagePrivacyLevel {
  /// Record image content.
  maskNone,

  /// Apply the native SDK's partial image masking policy.
  ///
  /// Android masks large content images. iOS records only bundled images and
  /// masks non-bundled images.
  maskLargeOnly,

  /// Mask all images.
  maskAll,
}

class FTSessionReplayManager {
  static final FTSessionReplayManager _singleton =
      FTSessionReplayManager._internal();

  factory FTSessionReplayManager() {
    return _singleton;
  }

  FTSessionReplayManager._internal();

  bool _configured = false;

  Future<void> setConfig(FTSessionReplayConfig config) async {
    if (_configured) {
      return;
    }
    _configured = true;
    await FTSessionReplay.init(config);
  }

  @visibleForTesting
  void resetForTesting() {
    _configured = false;
    resetSessionReplay();
  }
}
