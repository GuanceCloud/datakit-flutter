import 'package:flutter/gestures.dart' hide PointerEvent;
import 'package:flutter/widgets.dart';
import '../ft_session_replay_flutter.dart';
import 'capture/pointer_capture.dart';
import 'sr_data_models.dart';
import 'session_replay_internal.dart';

class SessionReplayCapture extends StatefulWidget {
  final FTSessionReplay? sessionReplay;
  final Widget child;

  const SessionReplayCapture({
    required Key key,
    required this.child,
    this.sessionReplay,
  }) : super(key: key);

  @override
  State<SessionReplayCapture> createState() => _SessionReplayCaptureState();
}

class _SessionReplayCaptureState extends State<SessionReplayCapture> {
  late PointerSnapshotRecorder pointerRecorder;
  FTSessionReplay? _registeredReplay;
  Key? _registeredKey;

  @override
  void initState() {
    super.initState();
    pointerRecorder = PointerSnapshotRecorder(const FTDefaultTimeProvider());
    FTSessionReplay.instanceListenable.addListener(_syncReplayRegistration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReplayRegistration();
  }

  @override
  void didUpdateWidget(SessionReplayCapture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key ||
        oldWidget.sessionReplay != widget.sessionReplay) {
      _unregisterReplay();
    }
    _syncReplayRegistration();
  }

  @override
  void dispose() {
    FTSessionReplay.instanceListenable.removeListener(_syncReplayRegistration);
    _unregisterReplay();
    super.dispose();
  }

  void _syncReplayRegistration() {
    if (!mounted) return;

    final replay = widget.sessionReplay ?? FTSessionReplay.instance;
    final key = widget.key;
    if (replay == null || key == null) {
      _unregisterReplay();
      return;
    }

    if (_registeredReplay == replay && _registeredKey == key) return;

    _unregisterReplay();
    replay.addElement(key, context as Element);
    _registeredReplay = replay;
    _registeredKey = key;
  }

  void _unregisterReplay() {
    final replay = _registeredReplay;
    final key = _registeredKey;
    if (replay != null && key != null) {
      replay.removeElement(key);
    }
    _registeredReplay = null;
    _registeredKey = null;
  }

  @override
  Widget build(BuildContext context) {
    _syncReplayRegistration();
    Widget builtChild = widget.child;

    final replay = widget.sessionReplay ?? FTSessionReplay.instance;
    if (replay?.defaultTouchPrivacyLevel == TouchPrivacyLevel.show) {
      builtChild = PointerSnapshotRecorderProvider(
        recorder: pointerRecorder,
        child: PointerRecorder(
          pointerRecorder: pointerRecorder,
          child: builtChild,
        ),
      );
    }
    return builtChild;
  }
}

@immutable
class SessionReplayPrivacy extends StatelessWidget {
  final Widget child;
  final bool? hide;
  final TextAndInputPrivacyLevel? textAndInputPrivacyLevel;
  final ImagePrivacyLevel? imagePrivacyLevel;
  final TouchPrivacyLevel? touchPrivacyLevel;

  const SessionReplayPrivacy({
    super.key,
    required this.child,
    this.hide,
    this.textAndInputPrivacyLevel,
    this.imagePrivacyLevel,
    this.touchPrivacyLevel,
  }) : super();

  @override
  Widget build(BuildContext context) {
    var builtWidget = child;
    if (touchPrivacyLevel == TouchPrivacyLevel.hide) {
      final pointerRecorderProvider =
          PointerSnapshotRecorderProvider.of(context);
      if (pointerRecorderProvider != null) {
        builtWidget = PointerUnrecorder(
          pointerRecorder: pointerRecorderProvider.recorder,
          child: builtWidget,
        );
      }
    }

    return builtWidget;
  }
}

@immutable
class PointerRecorder extends StatelessWidget {
  final PointerSnapshotRecorder pointerRecorder;
  final Widget child;

  const PointerRecorder({
    super.key,
    required this.pointerRecorder,
    required this.child,
  });

  void _onPointerDown(PointerDownEvent event) =>
      _capturePointerEvent(SRPointerEventType.down, event);

  void _onPointerMove(PointerMoveEvent event) =>
      _capturePointerEvent(SRPointerEventType.move, event);

  void _onPointerCancel(PointerCancelEvent event) =>
      _capturePointerEvent(SRPointerEventType.up, event);

  void _onPointerHover(PointerHoverEvent event) =>
      _capturePointerEvent(SRPointerEventType.move, event);

  void _onPointerUp(PointerUpEvent event) =>
      _capturePointerEvent(SRPointerEventType.up, event);

  void _capturePointerEvent(SRPointerEventType type, PointerEvent event) {
    pointerRecorder.capturePointer(
      event.pointer,
      type,
      event.position.dx,
      event.position.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerCancel: _onPointerCancel,
      onPointerHover: _onPointerHover,
      onPointerUp: _onPointerUp,
      child: child,
    );
  }
}

@immutable
class PointerUnrecorder extends StatelessWidget {
  final PointerSnapshotRecorder pointerRecorder;
  final Widget child;

  const PointerUnrecorder({
    super.key,
    required this.pointerRecorder,
    required this.child,
  });

  void _onPointerDown(PointerDownEvent event) =>
      pointerRecorder.uncapturePointer(event.pointer);
  void _onPointerMove(PointerMoveEvent event) =>
      pointerRecorder.uncapturePointer(event.pointer);
  void _onPointerCancel(PointerCancelEvent event) =>
      pointerRecorder.uncapturePointer(event.pointer);
  void _onPointerHover(PointerHoverEvent event) =>
      pointerRecorder.uncapturePointer(event.pointer);
  void _onPointerUp(PointerUpEvent event) =>
      pointerRecorder.uncapturePointer(event.pointer);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerCancel: _onPointerCancel,
      onPointerHover: _onPointerHover,
      onPointerUp: _onPointerUp,
      child: child,
    );
  }
}
