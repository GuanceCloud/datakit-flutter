import 'package:agent_example/ft_tracing_custom_dio.dart';
import 'package:agent_example/ft_tracing_custom_http.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:http/io_client.dart';

const String requestUrl = String.fromEnvironment("WEB_VIEW_URL")+"/api/user";


class CustomTracingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Tracing (Manual)"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("http"),
            onTap: () async {
              final client = FTTracingHttpClient();
              var response = await client.get(Uri.parse(requestUrl));
              FTLogger().logging(response.body, FTLogStatus.info);
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
      var dio = Dio();
      dio.interceptors.add(new FTInterceptor());
      var response = await dio.get(requestUrl);
      print(response);
    } catch (e) {
      print(e);
    }
  }
}

class AutoTracingPage extends StatelessWidget {
  final client = IOClient();
  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Network Tracing (Auto)")),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("http"),
            onTap: () async {
              var response = await client.get(Uri.parse(requestUrl));
              print(response.body);
            },
          ),
          ListTile(
            title: Text("dio"),
            onTap: () async {
              var response = await dio.get(requestUrl);
              print(response.data);
            },
          ),
        ],
      ),
    );
  }
}
