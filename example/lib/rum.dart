import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'ft_tracing_dio.dart';

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
              try {
                var dio = Dio();
                dio.interceptors.add(new FTInterceptor());
                var response = await dio.get('http://www.google.cn');
                print(response);
              } catch (e) {
                print(e);
              }
            },
          ),
        ],
      ),
    );
  }
}
