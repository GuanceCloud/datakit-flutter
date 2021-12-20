import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:uuid/uuid.dart';

class RUM extends StatefulWidget {
  @override
  _RUMState createState() => _RUMState();
}

class _RUMState extends State<RUM> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RUM 数据采集"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("Action 点击"),
            onTap: () {
              FTRUMManager().startAction("[ListTile][Action 点击]", "click");
            },
          ),
          ListTile(
            title: Text("View Start"),
            onTap: () {
              FTRUMManager().starView("RUM", "");
            },
          ),
          ListTile(
            title: Text("View Stop"),
            onTap: () {
              FTRUMManager().stopView();
            },
          ),
          ListTile(
            title: Text("Resource Normal"),
            onTap: () async {
              httpClientGetHttp('http://www.google.cn');
            },
          ),
          ListTile(
            title: Text("Resource Error"),
            onTap: () async {
              httpClientGetHttp('https://console-api.guance.com/not/found/');
            },
          ),
          ListTile(
            title: Text("Add Error"),
            onTap: () async {
              FTRUMManager().addCustomError("error stack", "error message");
            },
          ),
          ListTile(
            title: Text("Add Flutter Error"),
            onTap: () async {
              throw new Exception("Flutter error");
            },
          ),
        ],
      ),
    );
  }

  void httpClientGetHttp(String url) async {
    var httpClient = new HttpClient();
    String key = Uuid().v4();
    HttpClientResponse? response;
    HttpClientRequest? request;
    try {
      request = await httpClient
          .getUrl(Uri.parse(url))
          .timeout(Duration(seconds: 10));
      FTRUMManager().startResource(key);
      response = await request.close();
    } finally {
      Map<String, dynamic> requestHeader = {};
      Map<String, dynamic> responseHeader = {};

      request!.headers.forEach((name, values) {
        requestHeader[name] = values;
      });
      var responseBody = "";
      if (response != null) {
        response.headers.forEach((name, values) {
          responseHeader[name] = values;
        });
        responseBody = await response.transform(Utf8Decoder()).join();
      }
      FTRUMManager().stopResource(key);
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
}
