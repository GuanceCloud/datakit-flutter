// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2025-Present Datadog, Inc.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../ft_session_replay.dart';
import '../../session_replay_platform.dart';
import '../../sr_data_models.dart';
import '../capture_node.dart';
import '../recorder.dart';
import '../view_tree_snapshot.dart';

// This size was chosen so that 'Content Image' would fit without
// overlapping other content in the replay.
const int _labelMinWidth = 125;

// Largest size of image we can process - larger than this and we
// start to hit concerns around memory usage and processing time.
// This is essentially an 800x800 image, with a raw size of 2meg
const int maxImageSize = 640000;

class ImageRecorder implements ElementRecorder {
  final KeyGenerator keyGenerator;

  const ImageRecorder(this.keyGenerator);

  @override
  List<Type> get handlesTypes => [RawImage, Image];

  @override
  CaptureNodeSemantics? captureSemantics(
    Element element,
    CapturedViewAttributes attributes,
    TreeCapturePrivacy capturePrivacy,
  ) {
    final widget = element.widget;
    if (widget is Image &&
        capturePrivacy.imagePrivacyLevel ==
            ImagePrivacyLevel.maskLargeOnly) {
      // Try to pull out an AssetImage from the image internals...
      final assetImage = _extractAssetImage(widget);

      if (assetImage != null) {
        // Loosen capturing for the tree under this asset
        return IgnoredElement(
          subtreeStrategy: CaptureNodeSubtreeStrategy.record,
          subtreePrivacy: TreeCapturePrivacy(
            textAndInputPrivacyLevel: capturePrivacy.textAndInputPrivacyLevel,
            imagePrivacyLevel: ImagePrivacyLevel.maskNone,
          ),
        );
      }
    }

    if (widget is! RawImage) return null;

    final uiImage = widget.image;
    if (uiImage == null) {
      // This image is likely still loading. We could put a placeholder here,
      // but we would then have to replace it later. Instead, we'll wait for
      // it to load before creating the capture node. We can, however,
      // ignore all children for the time being.
      return IgnoredElement(subtreeStrategy: CaptureNodeSubtreeStrategy.ignore);
    }

    final elementId = keyGenerator.keyForElement(element);
    // AssetImages loosen their masking to [ImagePrivacyLevel.maskNone] when
    // they need to, so if [ImagePrivacyLevel.maskLargeOnly] is still set, then
    // we shouldn't capture this image.
    bool shouldCaptureImage =
        capturePrivacy.imagePrivacyLevel == ImagePrivacyLevel.maskNone;
    if (!shouldCaptureImage) {
      return SpecificElement(
        subtreeStrategy: CaptureNodeSubtreeStrategy.ignore,
        nodes: [
          PlaceholderNode(
            attributes,
            wireframeId: elementId,
            caption: 'Image',
            minWidth: _labelMinWidth,
          ),
        ],
      );
    }

    final totalPixelSize = uiImage.width * uiImage.height;
    if (totalPixelSize > maxImageSize) {
      return SpecificElement(
        subtreeStrategy: CaptureNodeSubtreeStrategy.ignore,
        nodes: [
          PlaceholderNode(
            attributes,
            wireframeId: elementId,
            caption: 'Large Image',
            minWidth: _labelMinWidth,
          ),
        ],
      );
    }

    final hasResourceKey = keyGenerator.hasImageKey(uiImage);
    if (hasResourceKey) {
      final resourceKey = keyGenerator.keyForImage(uiImage);
      return SpecificElement(
        subtreeStrategy: CaptureNodeSubtreeStrategy.ignore,
        nodes: [
          ResourceImageNode(
            attributes,
            wireframeId: elementId,
            resourceKey: resourceKey,
          ),
        ],
      );
    }

    return AdditionalProcessingElement(
      subtreeStrategy: CaptureNodeSubtreeStrategy.ignore,
      process: () => _captureImage(elementId, element, attributes, widget),
    );
  }

  Future<CaptureNodeSemantics> _captureImage(
    int elementId,
    Element element,
    CapturedViewAttributes attributes,
    RawImage widget,
  ) async {
    final List<CaptureNode> nodes = [];
    final image = widget.image;
    if (image != null) {
      // Prevent conversion of the image data to speed things up, we're going to
      // be hashing / compressing in the processor anyway
      ByteData? byteData = await image.toByteData(
        format: ImageByteFormat.rawRgba,
      );
      if (byteData != null) {
        final resourceKey = keyGenerator.keyForImage(image);
        await FTSessionReplayPlatform.instance.saveImageForProcessing(
          resourceKey,
          image.width,
          image.height,
          byteData,
        );
        nodes.add(
          ResourceImageNode(
            attributes,
            wireframeId: elementId,
            resourceKey: resourceKey,
          ),
        );
      }
    }

    if (nodes.isEmpty) {
      nodes.add(
        PlaceholderNode(
          attributes,
          wireframeId: elementId,
          caption: 'Empty Image',
          minWidth: _labelMinWidth,
        ),
      );
    }

    return SpecificElement(
      subtreeStrategy: CaptureNodeSubtreeStrategy.ignore,
      nodes: nodes,
    );
  }

  AssetBundleImageProvider? _extractAssetImage(Image widget) {
    AssetBundleImageProvider? assetImage;
    if (widget.image is AssetBundleImageProvider) {
      assetImage = widget.image as AssetBundleImageProvider;
    } else if (widget.image is ResizeImage) {
      final resizeImage = widget.image as ResizeImage;
      if (resizeImage.imageProvider is AssetBundleImageProvider) {
        assetImage = resizeImage.imageProvider as AssetBundleImageProvider;
      }
    }
    return assetImage;
  }
}

@immutable
@visibleForTesting
class ResourceImageNode extends CaptureNode {
  final int wireframeId;
  final int resourceKey;

  const ResourceImageNode(
    super.attributes, {
    required this.wireframeId,
    required this.resourceKey,
  });

  @override
  List<SRWireframe> buildWireframes() {
    final resourceId = FTSessionReplayPlatform.instance.resourceIdForKey(
      resourceKey,
    );

    return [
      SRImageWireframe(
        id: wireframeId,
        x: attributes.x,
        y: attributes.y,
        width: attributes.width,
        height: attributes.height,
        resourceId: resourceId,
      ),
    ];
  }
}
