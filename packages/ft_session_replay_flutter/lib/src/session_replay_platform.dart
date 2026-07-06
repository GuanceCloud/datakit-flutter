import 'dart:async';
import 'package:flutter/foundation.dart';

import 'const.dart';
import 'rum_context.dart';

class FTSessionReplaySampleState {
  final bool sampled;
  final bool sampledForErrorReplay;

  const FTSessionReplaySampleState({
    required this.sampled,
    required this.sampledForErrorReplay,
  });
}

class FTSessionReplayPlatform {
  static FTSessionReplayPlatform instance = FTMethodChannelSessionReplayPlatform();

  Object? get isolateToken => null;

  FutureOr<bool> enable(
    Map<String, dynamic> configuration,
    void Function(RUMContext) onContextChanged,
  ) async => true;

  FutureOr<RUMContext?> getCurrentContext() => null;

  bool get sessionReplaySampled => true;

  bool get sessionReplaySampledForErrorReplay => false;

  void setSampleStateChangedHandler(
    void Function(FTSessionReplaySampleState state)? handler,
  ) {}

  FutureOr<void> setHasReplay(String viewId, bool hasReplay) {}

  FutureOr<void> setRecordCount(String viewId, int count) {}

  FutureOr<void> writeSegment(String record, String viewId) {}

  FutureOr<void> telemetryDebug(String id, String message) {}

  FutureOr<void> telemetryError(String message, String kind, String stack) {}

  FutureOr<void> saveImageForProcessing(
    int resourceKey,
    int width,
    int height,
    ByteData byteData,
  ) {}

  String? resourceIdForKey(int resourceKey) => null;
}

class FTMethodChannelSessionReplayPlatform extends FTSessionReplayPlatform {
  final Map<int, String> _resourceIds = <int, String>{};
  bool _sessionReplaySampled = true;
  bool _sessionReplaySampledForErrorReplay = false;
  bool _sampleStateChannelConfigured = false;
  void Function(FTSessionReplaySampleState state)? _sampleStateChangedHandler;

  @override
  bool get sessionReplaySampled => _sessionReplaySampled;

  @override
  bool get sessionReplaySampledForErrorReplay =>
      _sessionReplaySampledForErrorReplay;

  @override
  void setSampleStateChangedHandler(
    void Function(FTSessionReplaySampleState state)? handler,
  ) {
    _sampleStateChangedHandler = handler;
    _ensureSampleStateChannel();
  }

  void _ensureSampleStateChannel() {
    if (_sampleStateChannelConfigured) return;
    _sampleStateChannelConfigured = true;
    sessionReplayStateChannel.setMethodCallHandler((call) async {
      if (call.method != methodSessionReplaySampleStateChanged) {
        return;
      }
      final arguments = call.arguments;
      final sampled = arguments is Map
          ? (_boolValue(arguments['sampled']) ?? false)
          : false;
      final sampledForErrorReplay = arguments is Map
          ? (_boolValue(arguments['sampledForErrorReplay']) ?? false)
          : false;
      _sessionReplaySampled = sampled;
      _sessionReplaySampledForErrorReplay = sampledForErrorReplay;
      _sampleStateChangedHandler?.call(FTSessionReplaySampleState(
        sampled: sampled,
        sampledForErrorReplay: sampledForErrorReplay,
      ));
    });
  }

  @override
  Future<bool> enable(
    Map<String, dynamic> configuration,
    void Function(RUMContext) onContextChanged,
  ) async {
    await channel.invokeMethod(methodSessionReplayConfig, configuration);
    return true;
  }

  @override
  Future<RUMContext?> getCurrentContext() async {
    final Object? data = await channel.invokeMethod(methodSessionReplayGetRumContext);
    if (data is! Map) return null;

    final applicationId = _stringValue(data['applicationId']) ??
        _stringValue(data['applicationID']) ??
        _stringValue(data['application_id']);
    final sessionId = _stringValue(data['sessionId']) ??
        _stringValue(data['sessionID']) ??
        _stringValue(data['session_id']);
    final viewId = _stringValue(data['viewId']) ??
        _stringValue(data['viewID']) ??
        _stringValue(data['view_id']);

    if (applicationId == null || sessionId == null || viewId == null) {
      return null;
    }

    final globalContext = <String, Object?>{};
    final rawGlobalContext = data['globalContext'] ?? data['bindInfo'];
    if (rawGlobalContext is Map) {
      rawGlobalContext.forEach((key, value) {
        if (key != null) globalContext[key.toString()] = value;
      });
    }

    return RUMContext(
      applicationId: applicationId,
      sessionId: sessionId,
      viewId: viewId,
      viewServerTimeOffset: (data['viewServerTimeOffset'] as num?)?.toDouble(),
      globalContext: globalContext,
    );
  }

  @override
  Future<void> setHasReplay(String viewId, bool hasReplay) async {
    await channel.invokeMethod(methodSessionReplaySetHasReplay, <String, dynamic>{
      'viewId': viewId,
      'hasReplay': hasReplay,
    });
  }

  @override
  Future<void> setRecordCount(String viewId, int count) async {
    await channel.invokeMethod(methodSessionReplaySetRecordCount, <String, dynamic>{
      'viewId': viewId,
      'count': count,
    });
  }

  @override
  Future<void> writeSegment(String record, String viewId) async {
    await channel.invokeMethod(methodSessionReplayWriteSegment, <String, dynamic>{
      'segment': record,
      'viewId': viewId,
    });
  }

  @override
  Future<void> telemetryDebug(String id, String message) async {
    try {
      await channel.invokeMethod(methodSessionReplayTelemetryDebug, <String, dynamic>{
        'id': id,
        'message': message,
      });
    } catch (_) {
      if (kDebugMode) debugPrint('[FT SessionReplay] $id: $message');
    }
  }

  @override
  Future<void> telemetryError(String message, String kind, String stack) async {
    try {
      await channel.invokeMethod(methodSessionReplayTelemetryError, <String, dynamic>{
        'message': message,
        'kind': kind,
        'stack': stack,
      });
    } catch (_) {
      if (kDebugMode) debugPrint('[FT SessionReplay] $kind: $message\n$stack');
    }
  }

  @override
  Future<void> saveImageForProcessing(
    int resourceKey,
    int width,
    int height,
    ByteData byteData,
  ) async {
    final Object? resourceId = await channel.invokeMethod(
      methodSessionReplaySaveImageResource,
      <String, dynamic>{
        'resourceKey': resourceKey,
        'width': width,
        'height': height,
        'bytes': byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      },
    );
    final id = _stringValue(resourceId);
    if (id != null) _resourceIds[resourceKey] = id;
  }

  @override
  String? resourceIdForKey(int resourceKey) => _resourceIds[resourceKey];

  String? _stringValue(Object? value) {
    final string = value?.toString();
    return string == null || string.isEmpty ? null : string;
  }

  bool? _boolValue(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return null;
  }
}
