import 'package:meta/meta.dart';

@immutable
class RUMContext {
  final String applicationId;
  final String sessionId;
  final String? viewId;
  final double? viewServerTimeOffset;
  final Map<String, Object?> globalContext;

  const RUMContext({
    required this.applicationId,
    required this.sessionId,
    this.viewId,
    this.viewServerTimeOffset,
    this.globalContext = const <String, Object?>{},
  });
}
