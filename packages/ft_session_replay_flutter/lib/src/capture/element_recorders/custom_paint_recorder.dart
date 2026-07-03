// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

import 'package:flutter/widgets.dart';

import '../../sr_data_models.dart';
import '../capture_node.dart';
import '../recorder.dart';
import '../view_tree_snapshot.dart';

/// Detects `CustomPaint` widgets and places a placeholder
/// in SessionReplay.
@immutable
class CustomPaintRecorder implements ElementRecorder {
  final KeyGenerator keyGenerator;

  const CustomPaintRecorder(this.keyGenerator);

  @override
  List<Type> get handlesTypes => [CustomPaint];

  @override
  CaptureNodeSemantics? captureSemantics(
    Element element,
    CapturedViewAttributes attributes,
    TreeCapturePrivacy capturePrivacy,
  ) {
    final widget = element.widget;
    if (widget is! CustomPaint) return null;

    // If there's only a foreground painter, this is a decoration
    // overlay that shouldn't be captured as a placeholder.
    if (widget.painter == null) return null;

    final elementId = keyGenerator.keyForElement(element);
    return AmbiguousElement(
      subtreeStrategy: CaptureNodeSubtreeStrategy.record,
      nodes: [CustomPaintNode(attributes, wireframeId: elementId)],
    );
  }
}

@immutable
class CustomPaintNode extends CaptureNode {
  final int wireframeId;

  const CustomPaintNode(super.attributes, {required this.wireframeId});

  @override
  List<SRWireframe> buildWireframes() {
    return [
      SRPlaceholderWireframe(
        id: wireframeId,
        x: attributes.x,
        y: attributes.y,
        width: attributes.width,
        height: attributes.height,
      ),
    ];
  }
}
