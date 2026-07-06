// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

import 'package:flutter/material.dart';

import '../../extensions.dart';
import '../capture_node.dart';
import '../recorder.dart';
import '../view_tree_snapshot.dart';
import 'common_nodes.dart';

class ContainerRecorder implements ElementRecorder {
  final KeyGenerator keyGenerator;

  const ContainerRecorder(this.keyGenerator);

  @override
  List<Type> get handlesTypes => [ColoredBox, Material, DecoratedBox];

  @override
  CaptureNodeSemantics? captureSemantics(
    Element element,
    CapturedViewAttributes attributes,
    TreeCapturePrivacy capturePrivacy,
  ) {
    final widget = element.widget;
    // Material is also considered a container
    if (widget is! ColoredBox &&
        widget is! Material &&
        widget is! DecoratedBox) {
      return null;
    }

    ContainerStyle? style;
    if (widget is Material) {
      style = _captureMaterialStyle(widget, attributes);
    } else if (widget is ColoredBox) {
      style = ContainerStyle(backgroundColor: widget.color.toHexString());
    } else if (widget is DecoratedBox) {
      final decoration = widget.decoration;
      style = ContainerStyle.fromDecoration(decoration, attributes);
      style ??= ContainerStyle(backgroundColor: null);
    }

    attributes = _adjustAttributesForShape(widget, attributes);

    final key = keyGenerator.keyForElement(element);
    final node = ContainerNode(attributes, wireframeId: key, style: style!);
    return AmbiguousElement(nodes: [node]);
  }

  ContainerStyle _captureMaterialStyle(
    Material widget,
    CapturedViewAttributes attributes,
  ) {
    Color? backgroundColor = widget.color;

    final surfaceTint = widget.surfaceTintColor;
    if (backgroundColor != null && surfaceTint != null) {
      // TODO: Check for useMaterial3
      backgroundColor = ElevationOverlay.applySurfaceTint(
        backgroundColor,
        surfaceTint,
        widget.elevation,
      );
    }

    final borderStyle = CapturedBorderStyle.fromShapeBorder(
      widget.shape,
      attributes,
    );

    return ContainerStyle(
      backgroundColor: backgroundColor?.toHexString(),
      borderColor: borderStyle?.color,
      borderWidth: borderStyle?.width,
      cornerRadius: borderStyle?.cornerRadius ?? 0.0,
    );
  }

  CapturedViewAttributes _adjustAttributesForShape(
    Widget widget,
    CapturedViewAttributes attributes,
  ) {
    CircleBorder? circleBorder;
    if (widget is Material && widget.shape is CircleBorder) {
      circleBorder = widget.shape as CircleBorder;
    } else if (widget is DecoratedBox) {
      final decoration = widget.decoration;
      if (decoration is ShapeDecoration && decoration.shape is CircleBorder) {
        circleBorder = decoration.shape as CircleBorder;
      }
    }
    if (circleBorder != null) {
      // Need to adjust position, width, and height so that this actually appears as
      // a circle in Session Replay
      final center = attributes.paintBounds.center;
      final shortSide = attributes.paintBounds.shortestSide;
      attributes = CapturedViewAttributes(
        paintBounds: Rect.fromCircle(center: center, radius: shortSide / 2),
        scaleX: attributes.scaleX,
        scaleY: attributes.scaleY,
      );
    }
    return attributes;
  }
}
