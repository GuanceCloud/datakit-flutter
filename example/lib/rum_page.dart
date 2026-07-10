import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_http_override_config.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:uuid/uuid.dart';

class RUMPage extends StatefulWidget {
  @override
  _RUMPageState createState() => _RUMPageState();
}

class _RUMPageState extends State<RUMPage> {
  static const int _nanosecondsPerMillisecond = 1000000;
  static const Duration _manualLongTaskDuration = Duration(milliseconds: 250);
  static const Duration _autoLongTaskDuration = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RUM Data Collection"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("Action Click"),
            onTap: () {
              FTRUMManager().startAction("[ListTile][Action Click]", "click",
                  property: {"action_property": "ft_value"});
            },
          ),
          ListTile(
            title: Text("Action Add"),
            onTap: () {
              FTRUMManager().addAction("Custom Action", "click",
                  property: {"action_property": "ft_value"});
            },
          ),
          ListTile(
            title: Text("View Start"),
            onTap: () {
              FTRUMManager()
                  .starView("RUM", property: {"starView_property": "ft_value"});
            },
          ),
          ListTile(
            title: Text("View Stop"),
            onTap: () {
              FTRUMManager()
                  .stopView(property: {"stopView_property": "ft_value"});
            },
          ),
          ListTile(
            title: Text("Resource Manual Normal"),
            onTap: () async {
              await httpClientGetHttp('https://httpbin.org/status/200');
            },
          ),
          ListTile(
            title: Text("Resource Manual Error"),
            onTap: () async {
              FTRUMManager().startAction("Resource Error Click", "click");
              await httpClientGetHttp('https://httpbin.org/status/404');
            },
          ),
          ListTile(
            title: Text("Resource Auto Reused Connection"),
            onTap: () async {
              await httpClientGetWithReusedConnection();
            },
          ),
          ListTile(
            title: Text("Add Error"),
            onTap: () async {
              FTRUMManager().addCustomError(
                "error stack", "error message",
                property: {"error_property": "ft_value"},
                // errorType: "custom_error_type"
              );
            },
          ),
          ListTile(
            title: Text("Add Flutter Error"),
            onTap: () async {
              throw new Exception("Flutter Error");
            },
          ),
          ListTile(
            title: Text("LongTask Manual Report"),
            onTap: () async {
              await FTRUMManager().addLongTask(
                "flutter_manual_long_task",
                _manualLongTaskDuration.inMilliseconds *
                    _nanosecondsPerMillisecond,
                property: {"long_task_source": "manual_report"},
              );
              _showSnackBar(
                  "Manual long task reported: ${_manualLongTaskDuration.inMilliseconds} ms");
            },
          ),
          ListTile(
            title: Text("LongTask Auto Detect"),
            onTap: () async {
              await FTRUMManager().startAction(
                "LongTask Auto Detect",
                "click",
                property: {"long_task_source": "auto_detect"},
              );
              _blockMainIsolate(_autoLongTaskDuration);
              _showSnackBar(
                  "Main isolate blocked for ${_autoLongTaskDuration.inMilliseconds} ms");
            },
          ),
          ListTile(
            title: Text("WebView"),
            onTap: () async {
              Navigator.pushNamed(context, "webview");
            },
          )
        ],
      ),
    );
  }

  Future<void> httpClientGetHttp(String url) async {
    final traceResource = FTHttpOverrideConfig.global.traceResource;
    FTHttpOverrideConfig.global.traceResource = false;
    final httpClient = HttpClient();
    String key = Uuid().v4();
    HttpClientResponse? response;
    HttpClientRequest? request;
    try {
      try {
        request = await httpClient
            .getUrl(Uri.parse(url))
            .timeout(Duration(seconds: 10));
        FTRUMManager().startResource(key,
            property: {"startResource_property": "ft_value"});
        response = await request.close();
      } finally {
        if (request != null) {
          Map<String, dynamic> requestHeader = {};
          Map<String, dynamic> responseHeader = {};

          request.headers.forEach((name, values) {
            requestHeader[name] = values.toString();
          });
          var responseBody = "";
          if (response != null) {
            response.headers.forEach((name, values) {
              responseHeader[name] = values.toString();
            });
            responseBody = await response.transform(Utf8Decoder()).join();
          }
          FTRUMManager().stopResource(key,
              property: {"stopResource_property": "ft_value"});
          FTRUMManager().addResource(
            key: key,
            url: request.uri.toString(),
            requestHeader: requestHeader,
            httpMethod: request.method,
            responseHeader: responseHeader,
            resourceStatus: response?.statusCode,
            responseBody: responseBody,
          );
        }
      }
    } finally {
      httpClient.close();
      FTHttpOverrideConfig.global.traceResource = traceResource;
    }
  }

  Future<void> httpClientGetWithReusedConnection() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final httpClient = HttpClient()..maxConnectionsPerHost = 1;
    final url = 'https://httpbin.org/status/200';

    server.listen((request) async {
      final responseBody = utf8.encode('reused connection');
      request.response
        ..headers.contentType = ContentType.text
        ..contentLength = responseBody.length
        ..persistentConnection = true
        ..add(responseBody);
      await request.response.close();
    });

    try {
      await _consumeHttpClientGet(httpClient, url);
      await _consumeHttpClientGet(httpClient, url);
      _showSnackBar(
          "Sent two local keep-alive requests. Check the second Resource.");
    } catch (e) {
      _showSnackBar("Reused connection request failed: $e");
    } finally {
      httpClient.close();
      await server.close(force: true);
    }
  }

  Future<void> _consumeHttpClientGet(HttpClient httpClient, String url) async {
    final request =
        await httpClient.getUrl(Uri.parse(url)).timeout(Duration(seconds: 10));
    request.persistentConnection = true;
    final response = await request.close().timeout(Duration(seconds: 10));
    await response.transform(Utf8Decoder()).join();
  }

  void _blockMainIsolate(Duration duration) {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < duration) {}
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
