import 'dart:io';

import 'package:ft_mobile_agent_flutter/ft_http_client.dart';

class FTHttpOverrideConfig {
  static final FTHttpOverrideConfig _singleton =
      FTHttpOverrideConfig._internal();

  FTHttpOverrideConfig._internal();

  bool _traceHeader = false;
  bool _traceResource = false;
  HttpOverrides? _customHttpOverrides;

  bool get traceHeader => _traceHeader;

  set traceHeader(bool value) {
    _traceHeader = value;
    if (value) {
      _setFTOverrides();
    }
  }

  bool get traceResource => _traceResource;

  set traceResource(bool value) {
    _traceResource = value;
    if (value) {
      _setFTOverrides();
    }
  }

  static get global {
    return _singleton;
  }

  bool Function(String url)? isInTakeUrl;

  HttpOverrides? get customHttpOverrides => _customHttpOverrides;

  set customHttpOverrides(HttpOverrides? value) {
    _customHttpOverrides = value;
  }

  void _setFTOverrides() {
    if (_customHttpOverrides != null) {
      HttpOverrides.global = _customHttpOverrides!;
    } else if (HttpOverrides.current is! FTHttpOverrides) {
      HttpOverrides.global = FTHttpOverrides();
    }
  }
}
