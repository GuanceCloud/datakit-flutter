import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/src/capture/capture_node.dart';
import 'package:ft_mobile_agent_flutter/src/capture/recorder.dart';
import 'package:ft_mobile_agent_flutter/src/capture/view_tree_snapshot.dart';
import 'package:ft_mobile_agent_flutter/src/processor/processor_worker.dart';
import 'package:ft_mobile_agent_flutter/src/rum_context.dart';
import 'package:ft_mobile_agent_flutter/src/session_replay_platform.dart';
import 'package:ft_mobile_agent_flutter/src/sr_data_models.dart';

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
}

CaptureResult _captureAt(
  DateTime date, {
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
      nodes: const <CaptureNode>[
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
