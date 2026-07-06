// Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.

import 'package:flutter/material.dart';

import '../sr_data_models.dart';

class IconTextTransform {
  SRTextWireframe apply(SRTextWireframe wireframe) {
    final fallback = _materialIconFallbackFor(
      wireframe.text,
      wireframe.textStyle.family,
    );
    if (fallback == null) {
      return wireframe;
    }

    return SRTextWireframe(
      id: wireframe.id,
      x: wireframe.x,
      y: wireframe.y,
      width: wireframe.width,
      height: wireframe.height,
      text: fallback,
      textStyle: SRTextStyle(
        color: wireframe.textStyle.color,
        family: '',
        size: wireframe.textStyle.size,
      ),
      border: wireframe.border,
      clip: wireframe.clip,
      shapeStyle: wireframe.shapeStyle,
      textPosition: wireframe.textPosition,
    );
  }

  String? _materialIconFallbackFor(String text, String? fontFamily) {
    if (!_isMaterialIconFont(fontFamily)) return null;

    final codePoints = text.runes.toList(growable: false);
    if (codePoints.length != 1) return null;

    return _materialIconFallbacks[codePoints.single];
  }

  bool _isMaterialIconFont(String? fontFamily) {
    return fontFamily == 'MaterialIcons' ||
        fontFamily == 'MaterialSymbolsOutlined' ||
        fontFamily == 'MaterialSymbolsRounded' ||
        fontFamily == 'MaterialSymbolsSharp';
  }
}

final Map<int, String> _materialIconFallbacks = _createMaterialIconFallbacks();

Map<int, String> _createMaterialIconFallbacks() {
  final fallbacks = <int, String>{};

  void add(IconData icon, List<int> legacyCodePoints, String fallback) {
    fallbacks[icon.codePoint] = fallback;
    for (final codePoint in legacyCodePoints) {
      fallbacks[codePoint] = fallback;
    }
  }

  add(Icons.arrow_back, const [0xe5c4], String.fromCharCode(0x2190));
  add(Icons.arrow_back_sharp, const [], String.fromCharCode(0x2190));
  add(Icons.arrow_back_rounded, const [], String.fromCharCode(0x2190));
  add(Icons.arrow_back_outlined, const [], String.fromCharCode(0x2190));
  add(Icons.arrow_back_ios, const [0xe5e0], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_sharp, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_rounded, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_outlined, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_new, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_new_sharp, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_new_rounded, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_back_ios_new_outlined, const [], String.fromCharCode(0x2039));
  add(Icons.arrow_forward, const [0xe5c8], String.fromCharCode(0x2192));
  add(Icons.arrow_upward, const [0xe5d8], String.fromCharCode(0x2191));
  add(Icons.arrow_downward, const [0xe5db], String.fromCharCode(0x2193));
  add(Icons.close, const [0xe5cd], 'x');

  return fallbacks;
}
