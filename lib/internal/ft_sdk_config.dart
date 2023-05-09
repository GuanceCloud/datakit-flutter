import 'dart:io';

import 'package:ft_mobile_agent_flutter/ft_http_client.dart';

bool get traceHeader => _traceHeader;

bool get traceResource => _traceResource;

bool _traceHeader = false;
bool _traceResource = false;

set traceHeader(bool set) {
  _traceHeader = set;
  if (set) {
    setFTOverrides();
  }
}

set traceResource(bool set) {
  _traceResource = set;
  if (set) {
    setFTOverrides();
  }
}

void setFTOverrides() {
  if (HttpOverrides.current != null) {
    if (HttpOverrides.current is FTHttpOverrides) {
      return;
    }
  }
  HttpOverrides.global = FTHttpOverrides();
}
