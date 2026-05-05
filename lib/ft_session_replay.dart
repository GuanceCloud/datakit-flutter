import 'const.dart';

class FTSessionReplayConfig {
  FTSessionReplayConfig({
    this.sampleRate,
    this.sessionReplayOnErrorSampleRate,
    this.touchPrivacy = FTTouchPrivacyLevel.hide,
    this.textAndInputPrivacy = FTTextAndInputPrivacyLevel.maskAll,
    this.imagePrivacy = FTImagePrivacyLevel.maskAll,
    this.enableLinkRUMKeys,
  })  : assert(sampleRate == null || (sampleRate >= 0 && sampleRate <= 1)),
        assert(sessionReplayOnErrorSampleRate == null ||
            (sessionReplayOnErrorSampleRate >= 0 &&
                sessionReplayOnErrorSampleRate <= 1));

  /// Sampling rate in range [0, 1]. Defaults to the native SDK default.
  final double? sampleRate;

  /// Error-session replay sampling rate in range [0, 1].
  final double? sessionReplayOnErrorSampleRate;

  final FTTouchPrivacyLevel touchPrivacy;
  final FTTextAndInputPrivacyLevel textAndInputPrivacy;
  final FTImagePrivacyLevel imagePrivacy;

  /// Additional RUM keys attached to replay records.
  final List<String>? enableLinkRUMKeys;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sampleRate': sampleRate,
      'sessionReplayOnErrorSampleRate': sessionReplayOnErrorSampleRate,
      'touchPrivacy': touchPrivacy.index,
      'textAndInputPrivacy': textAndInputPrivacy.index,
      'imagePrivacy': imagePrivacy.index,
      'enableLinkRUMKeys': enableLinkRUMKeys,
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

  Future<void> setConfig(FTSessionReplayConfig config) async {
    await channel.invokeMethod(methodSessionReplayConfig, config.toMap());
  }
}
