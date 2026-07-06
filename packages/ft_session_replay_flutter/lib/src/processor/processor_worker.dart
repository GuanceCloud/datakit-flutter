// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../capture/pointer_capture.dart';
import '../capture/recorder.dart';
import '../capture/view_tree_snapshot.dart';
import '../session_replay_platform.dart';
import '../sr_data_models.dart';
import 'diff.dart';
import 'icon_text_transform.dart';

/// An internal class that does all of the work for processing a ViewSnapshot into SRRecords,
/// including creating diffs for non full records. When complete, the processor sends
/// the records to the native method channel so they can be serialized and sent to intake.
class ProcessorWorker {
  @visibleForTesting
  static const fullSnapshotInterval = Duration(seconds: 20);

  ViewTreeSnapshot? _lastSnapshot;
  List<SRWireframe>? _lastWireframes;
  DateTime? _lastFullSnapshotAt;
  bool _sampledForErrorReplay = false;
  final Map<String, int> _recordCountByViewId = {};
  final IconTextTransform _iconTextTransform = IconTextTransform();

  void reset() {
    _lastSnapshot = null;
    _lastWireframes = null;
    _lastFullSnapshotAt = null;
  }

  void setSampledForErrorReplay(bool sampledForErrorReplay) {
    _sampledForErrorReplay = sampledForErrorReplay;
  }

  Future<void> processSnapshot(CaptureResult snapshot) async {
    final viewSnapshot = snapshot.viewTreeSnapshot;
    final viewId = viewSnapshot.context.viewId;
    if (viewId == null) return;

    final wireframes = generateWireframes(snapshot);
    var records = <SRRecord>[];

    final timestamp = viewSnapshot.date.toUtc().millisecondsSinceEpoch;

    final isNewView = viewSnapshot.context.applicationId !=
            _lastSnapshot?.context.applicationId ||
        viewSnapshot.context.sessionId != _lastSnapshot?.context.sessionId ||
        viewSnapshot.context.viewId != _lastSnapshot?.context.viewId;
    final isTimeForFullSnapshot =
        _isTimeForFullSnapshot(viewSnapshot.date, isNewView);
    final fullSnapshotRequired = isNewView || isTimeForFullSnapshot;

    if (fullSnapshotRequired) {
      // Generate full snapshot
      records.add(
        SRMetaRecord(
          data: SRMetaRecordData(
            width: viewSnapshot.viewportSize.width.toInt(),
            height: viewSnapshot.viewportSize.height.toInt(),
          ),
          timestamp: timestamp,
        ),
      );
      records.add(
        SRFocusRecord(
          data: SRFocusRecordData(hasFocus: true),
          timestamp: timestamp,
        ),
      );
      records.add(
        SRFullSnapshotRecord(
          data: SRFullSnapshotRecordData(wireframes: wireframes),
          timestamp: timestamp,
        ),
      );
    } else if (_lastWireframes != null) {
      final incrementalRecord = _createIncrementalRecord(
        viewSnapshot,
        wireframes,
        _lastWireframes!,
      );
      if (incrementalRecord != null) {
        records.add(incrementalRecord);
      }
    }

    final pointerSnapshot = snapshot.pointerSnapshot;
    if (pointerSnapshot != null && pointerSnapshot.pointerEvents.isNotEmpty) {
      records.addAll(
        pointerSnapshot.pointerEvents.map(_createIncrementalPointerRecord),
      );
    }

    if (records.isNotEmpty) {
      final enrichedRecord = SREnrichedRecord(
        records: records,
        applicationID: viewSnapshot.context.applicationId,
        sessionID: viewSnapshot.context.sessionId,
        viewID: viewId,
        globalContext: viewSnapshot.context.globalContext.isEmpty
            ? null
            : viewSnapshot.context.globalContext,
      );

      var totalRecordCount = _recordCountByViewId[viewId] ?? 0;
      totalRecordCount += records.length;
      _recordCountByViewId[viewId] = totalRecordCount;
      // We don't have to wait for this to respond before sending the segment. They'll
      // still be processed in order and this gives us more time to perform the encode.
      FTSessionReplayPlatform.instance.setRecordCount(
        viewId,
        totalRecordCount,
      );

      try {
        var encoded = jsonEncode(enrichedRecord);
        await FTSessionReplayPlatform.instance.writeSegment(
          encoded,
          viewId,
        );
      } catch (e, st) {
        FTSessionReplayPlatform.instance.telemetryError(
          'Error writing segment: $e',
          e.runtimeType.toString(),
          st.toString(),
        );
      }
    }

    _lastSnapshot = viewSnapshot;
    _lastWireframes = wireframes;
  }

  bool _isTimeForFullSnapshot(DateTime snapshotTime, bool isNewView) {
    if (!_sampledForErrorReplay) {
      return false;
    }
    if (isNewView || _lastFullSnapshotAt == null) {
      _lastFullSnapshotAt = snapshotTime;
      return true;
    }
    if (snapshotTime.difference(_lastFullSnapshotAt!) >= fullSnapshotInterval) {
      _lastFullSnapshotAt = snapshotTime;
      return true;
    }
    return false;
  }

  @visibleForTesting
  List<SRWireframe> generateWireframes(CaptureResult result) {
    return result.viewTreeSnapshot.nodes
        .expand((element) => element.buildWireframes())
        .map((wireframe) {
      if (wireframe is SRTextWireframe) {
        return _iconTextTransform.apply(wireframe);
      }
      return wireframe;
    }).toList();
  }

  SRRecord _createIncrementalPointerRecord(PointerCapture pointer) {
    return SRIncrementalSnapshotRecord(
      data: SRPointerInteractionData(
        pointerEventType: pointer.eventType,
        pointerId: pointer.pointerId,
        pointerType: SRPointerType.touch,
        x: pointer.x,
        y: pointer.y,
      ),
      timestamp: pointer.date.millisecondsSinceEpoch,
    );
  }

  SRRecord? _createIncrementalRecord(
    ViewTreeSnapshot viewTreeSnapshot,
    List<SRWireframe> wireframes,
    List<SRWireframe> lastWireframes,
  ) {
    final timestamp = viewTreeSnapshot.date.toUtc().millisecondsSinceEpoch;
    try {
      final diff = computeDiff(lastWireframes, wireframes);
      if (diff.isEmpty) {
        return null;
      }
      return SRIncrementalSnapshotRecord(
        data: SRIncrementalMutationData(
          adds: diff.adds,
          removes: diff.removes,
          updates: diff.updates,
        ),
        timestamp: timestamp,
      );
    } catch (_) {
      // default back to full snaposhot
      return SRFullSnapshotRecord(
        data: SRFullSnapshotRecordData(wireframes: wireframes),
        timestamp: timestamp,
      );
    }
  }
}
