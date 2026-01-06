import 'dart:io';

import 'package:ft_mobile_agent_flutter/ft_http_client.dart';

/// Custom Http Overrides
class CustomHttpOverrides extends FTHttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
        // ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        //   return true;
        // }
        ;
  }
}

/// FTHttpOverrideConfig.global.traceHeader  FTTracer.setConfig(enableNativeAutoTrace)
class CustomClientHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FTHttpClient(super.createHttpClient(context));
  }
}
/// Http Proxy
class HttpProxy extends FTHttpOverrides {
  String host;
  String port;

  HttpProxy._(this.host, this.port);

  static HttpProxy createHttpProxy(String host, String port) {
    return HttpProxy._(host, port);
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    /// Ignore SSL certificate verification
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (environment == null) {
      environment = {};
    }
    environment['http_proxy'] = '$host:$port';
    environment['https_proxy'] = '$host:$port';
    return super.findProxyFromEnvironment(url, environment);
  }
}
