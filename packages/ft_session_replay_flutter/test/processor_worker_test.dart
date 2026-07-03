import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_session_replay_flutter/src/capture/capture_node.dart';
import 'package:ft_session_replay_flutter/src/capture/element_recorders/common_nodes.dart';
import 'package:ft_session_replay_flutter/src/capture/recorder.dart';
import 'package:ft_session_replay_flutter/src/capture/view_tree_snapshot.dart';
import 'package:ft_session_replay_flutter/src/processor/processor_worker.dart';
import 'package:ft_session_replay_flutter/src/rum_context.dart';
import 'package:ft_session_replay_flutter/src/session_replay_platform.dart';
import 'package:ft_session_replay_flutter/src/sr_data_models.dart';

void main() {
  late FTSessionReplayPlatform previousPlatform;
  late _FakeSessionReplayPlatform fakePlatform;

  setUp(() {
    previousPlatform = FTSessionReplayPlatform.instance;
    fakePlatform = _FakeSessionReplayPlatform();
    FTSessionReplayPlatform.instance = fakePlatform;
  });

  tearDown(() {
    FTSessionReplayPlatform.instance = previousPlatform;
  });

  test('error sampling emits periodic full snapshots', () async {
    final worker = ProcessorWorker()..setSampledForErrorReplay(true);
    final start = DateTime.utc(2026, 1, 1);

    await worker.processSnapshot(_captureAt(start));
    expect(fakePlatform.segments, hasLength(1));
    expect(_recordTypes(fakePlatform.segments.last), <int>[
      SRRecord.metaRecordType,
      SRRecord.focusRecordType,
      SRRecord.fullSnapshotRecordType,
    ]);

    await worker.processSnapshot(
      _captureAt(start.add(const Duration(seconds: 10))),
    );
    expect(fakePlatform.segments, hasLength(1));

    await worker.processSnapshot(
      _captureAt(start.add(ProcessorWorker.fullSnapshotInterval)),
    );
    expect(fakePlatform.segments, hasLength(2));
    expect(_recordTypes(fakePlatform.segments.last), <int>[
      SRRecord.metaRecordType,
      SRRecord.focusRecordType,
      SRRecord.fullSnapshotRecordType,
    ]);
  });

  test('normal sampling does not emit periodic full snapshots', () async {
    final worker = ProcessorWorker()..setSampledForErrorReplay(false);
    final start = DateTime.utc(2026, 1, 1);

    await worker.processSnapshot(_captureAt(start));
    await worker.processSnapshot(
      _captureAt(start.add(const Duration(seconds: 40))),
    );

    expect(fakePlatform.segments, hasLength(1));
  });

  test('switching to error sampling emits a full snapshot immediately',
      () async {
    final worker = ProcessorWorker()..setSampledForErrorReplay(false);
    final start = DateTime.utc(2026, 1, 1);

    await worker.processSnapshot(_captureAt(start));
    expect(fakePlatform.segments, hasLength(1));

    worker.setSampledForErrorReplay(true);
    await worker.processSnapshot(
      _captureAt(start.add(const Duration(seconds: 1))),
    );

    expect(fakePlatform.segments, hasLength(2));
    expect(_recordTypes(fakePlatform.segments.last), <int>[
      SRRecord.metaRecordType,
      SRRecord.focusRecordType,
      SRRecord.fullSnapshotRecordType,
    ]);
  });

  test('writes linked RUM keys into segment globalContext', () async {
    final worker = ProcessorWorker();

    await worker.processSnapshot(_captureAt(
      DateTime.utc(2026, 1, 1),
      globalContext: const <String, Object?>{
        'wgt_id': 'widget-id',
        'rum_key': 'rum-value',
      },
    ));

    expect(fakePlatform.segments, hasLength(1));
    final payload =
        jsonDecode(fakePlatform.segments.single) as Map<String, dynamic>;
    expect(payload['globalContext'], <String, dynamic>{
      'wgt_id': 'widget-id',
      'rum_key': 'rum-value',
    });
  });

  test(
      'generateWireframes maps Material icon text to font-independent fallback',
      () {
    final worker = ProcessorWorker();
    final result = _captureWithNodes(
      DateTime.utc(2026, 1, 1),
      <CaptureNode>[
        TextElementCaptureNode(
          const CapturedViewAttributes(
            paintBounds: Rect.fromLTWH(0, 0, 24, 24),
            scaleX: 1,
            scaleY: 1,
          ),
          wireframeId: 1,
          text: String.fromCharCode(Icons.arrow_back.codePoint),
          color: '#000000ff',
          family: 'MaterialIcons',
          size: 24,
          alignment: SRHorizontalAlignment.left,
        ),
        TextElementCaptureNode(
          const CapturedViewAttributes(
            paintBounds: Rect.fromLTWH(24, 0, 24, 24),
            scaleX: 1,
            scaleY: 1,
          ),
          wireframeId: 2,
          text: String.fromCharCode(Icons.arrow_back_ios_new_rounded.codePoint),
          color: '#000000ff',
          family: 'MaterialIcons',
          size: 24,
          alignment: SRHorizontalAlignment.left,
        ),
      ],
    );

    final wireframes =
        worker.generateWireframes(result).cast<SRTextWireframe>();

    expect(wireframes, hasLength(2));
    expect(wireframes[0].text, String.fromCharCode(0x2190));
    expect(wireframes[0].textStyle.family, isEmpty);
    expect(wireframes[1].text, String.fromCharCode(0x2039));
    expect(wireframes[1].textStyle.family, isEmpty);
  });
}

CaptureResult _captureAt(
  DateTime date, {
  Map<String, Object?> globalContext = const <String, Object?>{},
}) {
  return _captureWithNodes(
    date,
    const <CaptureNode>[
      PlaceholderNode(
        CapturedViewAttributes(
          paintBounds: Rect.fromLTWH(0, 0, 10, 10),
          scaleX: 1,
          scaleY: 1,
        ),
        wireframeId: 1,
        caption: 'box',
        minWidth: 0,
      ),
    ],
    globalContext: globalContext,
  );
}

CaptureResult _captureWithNodes(
  DateTime date,
  List<CaptureNode> nodes, {
  Map<String, Object?> globalContext = const <String, Object?>{},
}) {
  return CaptureResult(
    ViewTreeSnapshot(
      date: date,
      context: RUMContext(
        applicationId: 'app-id',
        sessionId: 'session-id',
        viewId: 'view-id',
        globalContext: globalContext,
      ),
      viewportSize: const Size(100, 100),
      nodes: nodes,
    ),
    null,
  );
}

List<int> _recordTypes(String segment) {
  final payload = jsonDecode(segment) as Map<String, dynamic>;
  return (payload['records'] as List<dynamic>)
      .map((record) => (record as Map<String, dynamic>)['type'] as int)
      .toList();
}

class _FakeSessionReplayPlatform extends FTSessionReplayPlatform {
  final List<String> segments = <String>[];
  final List<String> calls = <String>[];

  @override
  Future<void> setRecordCount(String viewId, int count) async {
    calls.add('setRecordCount:$viewId:$count');
  }

  @override
  Future<void> writeSegment(String record, String viewId) async {
    calls.add('writeSegment:$viewId');
    segments.add(record);
  }
}
