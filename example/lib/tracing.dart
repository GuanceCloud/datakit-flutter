import 'dart:io';

import 'package:agent_example/ft_tracing_http.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

import 'ft_tracing_dio.dart';

class Tracing extends StatefulWidget {
  @override
  _TracingState createState() => _TracingState();
}

class _TracingState extends State<Tracing> {
  static final client = FTTracingHttpClient();
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    dio.interceptors.add(new FTInterceptor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("网络链路追踪"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("HttpClient"),
            onTap: () {
              httpClientGetHttp();
            },
          ),
          ListTile(
            title: Text("http"),
            onTap: () {
              client.get(Uri.parse("http://www.google.cn"));
            },
          ),
          ListTile(
            title: Text("dio"),
            onTap: () {
              dioGetHttp();
            },
          ),
        ],
      ),
    );
  }

  void dioGetHttp() async {
    try {
      var response = await dio.get('http://www.google.cn');
      print(response);
    } catch (e) {
      print(e);
    }
  }

  void httpClientGetHttp() async {
    var url = 'http://www.google.cn';
    var httpClient = new HttpClient();
    String key = DateTime.now().millisecondsSinceEpoch.toString()+url;
    String errorMessage = "";
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse? response;
    try {
      final traceHeaders =
          await FTTracer().getTraceHeader(key, request.uri.toString());
      traceHeaders.forEach((key, value) {
        request.headers.add(key, value);
      });
      response = await request.close();
    } catch (exception) {
      errorMessage = exception.toString();
    } finally{
      Map<String,dynamic> requestHeader = {};
      Map<String,dynamic> responseHeader = {};

      request.headers.forEach((name, values) {
        requestHeader[name] = values;
      });
      if (response != null){
        response.headers.forEach((name, values) {
          responseHeader[name] = values;
        });
      }
      FTTracer().addTrace(
          key: key,
          url: request.uri,
          httpMethod: request.method,
          responseHeader: responseHeader,
          requestHeader: requestHeader,
          statusCode: response?.statusCode,
          errorMessage: errorMessage);
    }
  }
}
