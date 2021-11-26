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
            onTap: (){
              FTRUMManager().startAction("[ListTile][Action 点击]", "click");
            },
          ),
          ListTile(
            title: Text("View Start"),
            onTap: (){
              FTRUMManager().starView("RUM", "");
            },
          ),
          ListTile(
            title: Text("View Stop"),
            onTap: (){
              FTRUMManager().stopView();
            },
          ),
          ListTile(
            title: Text("Resource"),
            onTap: () async {
              httpClientGetHttp();
            },
          ),
        ],
      ),
    );
  }
  void httpClientGetHttp() async {
    var url = 'http://www.google.cn';
    var httpClient = new HttpClient();
    String key = Uuid().v4();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse? response;
    try {
      FTRUMManager().startResource(key);
      response = await request.close();
    } finally{
      Map<String,dynamic> requestHeader = {};
      Map<String,dynamic> responseHeader = {};

      request.headers.forEach((name, values) {
        requestHeader[name] = values;
      });
      var responseBody = "";
      if (response != null){
        response.headers.forEach((name, values) {
          responseHeader[name] = values;
        });
        responseBody = await response.transform(Utf8Decoder()).join();
      }
      FTRUMManager().addResource(
        key: key,
        url:request.uri.toString(),
        requestHeader: requestHeader,
        httpMethod: request.method,
        responseHeader:responseHeader,
        resourceStatus: response?.statusCode,
        responseBody: responseBody,
      );
      FTRUMManager().stopResource(key);
    }

  }

}
