import 'package:flutter/services.dart';

const MethodChannel channel = MethodChannel('ft_session_replay_flutter');

const methodSessionReplayConfig = 'ftSessionReplayConfig';
const methodSessionReplayGetRumContext = 'ftSessionReplayGetRumContext';
const methodSessionReplaySetHasReplay = 'ftSessionReplaySetHasReplay';
const methodSessionReplaySetRecordCount = 'ftSessionReplaySetRecordCount';
const methodSessionReplayWriteSegment = 'ftSessionReplayWriteSegment';
const methodSessionReplayTelemetryDebug = 'ftSessionReplayTelemetryDebug';
const methodSessionReplayTelemetryError = 'ftSessionReplayTelemetryError';
const methodSessionReplaySaveImageResource = 'ftSessionReplaySaveImageResource';

const MethodChannel sessionReplayStateChannel =
    MethodChannel('ft_session_replay_flutter/session_replay');
const methodSessionReplaySampleStateChanged =
    'ftSessionReplaySampleStateChanged';
