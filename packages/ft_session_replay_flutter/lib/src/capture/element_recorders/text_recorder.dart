// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

import 'package:flutter/material.dart';

import '../../../ft_session_replay_flutter.dart';
import '../../extensions.dart';
import '../capture_node.dart';
import '../recorder.dart';
import '../text_masking.dart';
import '../view_tree_snapshot.dart';
import 'common_nodes.dart';
import 'recording_extensions.dart';

class TextElementRecorder implements ElementRecorder {
  final KeyGenerator keyGenerator;

  const TextElementRecorder(this.keyGenerator);

  @override
  List<Type> get handlesTypes => [RichText];

  @override
  CaptureNodeSemantics? captureSemantics(
    Element element,
    CapturedViewAttributes attributes,
    TreeCapturePrivacy capturePrivacy,
  ) {
    final widget = element.widget;
    if (widget is! RichText) {
      return null;
    }

    final textSpan = widget.text;
    if (textSpan is TextSpan) {
      final style = textSpan.style;
      final alignment = widget.textAlign.getSrHorizontalAlignment(
        widget.textDirection,
      );

      // For now, contact all child spans into a single string.
      // TODO(RUM-10230: Research how to support inline spans with different styles
      final stringBuilder = StringBuffer();
      bool hasWidgetChildern = _getText(
        textSpan,
        stringBuilder,
        capturePrivacy.textAndInputPrivacyLevel,
      );

      final node = TextElementCaptureNode(
        attributes,
        wireframeId: keyGenerator.keyForElement(element),
        text: stringBuilder.toString(),
        color: style?.color?.toHexString() ?? Colors.black.toHexString(),
        family: style?.fontFamily ?? '',
        size: ((style?.fontSize?.toInt() ?? 10) * attributes.scaleX).toInt(),
        alignment: alignment,
      );

      return SpecificElement(
        subtreeStrategy: hasWidgetChildern
            ? CaptureNodeSubtreeStrategy.record
            : CaptureNodeSubtreeStrategy.ignore,
        nodes: [node],
      );
    }
    return null;
  }

  bool _getText(
    TextSpan span,
    StringBuffer buffer,
    TextAndInputPrivacyLevel privacy,
  ) {
    bool hasWidgetChildren = false;
    final text = span.text;
    if (text != null) {
      if (privacy == TextAndInputPrivacyLevel.maskAll) {
        final masked = maskTextPreservingSpaces(text);
        buffer.write(masked);
      } else {
        buffer.write(text);
      }
    }

    span.children?.forEach((inlineSpan) {
      if (inlineSpan is TextSpan) {
        hasWidgetChildren |= _getText(inlineSpan, buffer, privacy);
      } else if (inlineSpan is WidgetSpan) {
        hasWidgetChildren = true;
      }
    });
    return hasWidgetChildren;
  }
}
