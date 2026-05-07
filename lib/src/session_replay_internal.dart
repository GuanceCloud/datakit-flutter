import 'package:flutter/foundation.dart';

abstract class FTTimeProvider {
  DateTime now();
}

class FTDefaultTimeProvider implements FTTimeProvider {
  const FTDefaultTimeProvider();

  @override
  DateTime now() => DateTime.now();
}

enum CoreLoggerLevel { debug, info, warn, error }

class FTSessionReplayLogger {
  const FTSessionReplayLogger();

  void log(CoreLoggerLevel level, String message) {
    if (kDebugMode) {
      debugPrint('[FT SessionReplay] ${level.name}: $message');
    }
  }

  void sendToDatadog(String message, StackTrace? stackTrace, String? kind) {
    if (kDebugMode) {
      debugPrint('[FT SessionReplay] telemetry: $message');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }
}

Future<T> wrapAsync<T>(
  String operationName,
  FTSessionReplayLogger logger,
  Map<String, Object?> attributes,
  Future<T> Function() operation,
) async {
  try {
    return await operation();
  } catch (e, st) {
    logger.sendToDatadog(
      'Session Replay operation $operationName failed: $e',
      st,
      e.runtimeType.toString(),
    );
    rethrow;
  }
}
