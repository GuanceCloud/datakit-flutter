import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeRoute(),
    );
  }

}
class HomeRoute extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeRoute> {
  var permissions = [Permission.location,Permission.camera,Permission.storage,Permission.phone];
  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) {
      requestPermission(permissions);
    }else if(Platform.isIOS){
      requestPermission([Permission.location]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildConfigWidget(),
              _buildSyncImmediateWidget(),
              _buildSyncListImmediateWidget(),
              _buildSyncWidget(),
              _buildFlowChartWidget(),
              _buildBindUserWidget(),
              _buildUnBindUserWidget(),
              _buildStopSDKWidget(),
            ],
          ),
        ),
    );
  }

  Widget _buildConfigWidget() {
    return RaisedButton(
      child: Text("设置配置"),
      onPressed: () async {
        /// 配置方法一
        FTMobileAgentFlutter.configX(
            Config("http://10.100.64.106:19457/v1/write/metrics")
                .setAK("accid", "accsk")
                .setDataKit("flutter_datakit")
                .setEnableLog(true)
                .setNeedBindUser(false)
                .setMonitorType(MonitorType.BATTERY | MonitorType.NETWORK | MonitorType.LOCATION)
        );

        /// 配置方法二
        /**FTMobileAgentFlutter.config(
            "http://10.100.64.106:19457/v1/write/metrics",
            akId: "accid",
            akSecret: "accsk",
            dataKitUUID: "flutter_datakit",
            enableLog: true,
            needBindUser: false,
            monitorType: MonitorType.ALL);*/
      },
    );
  }

  Widget _buildSyncImmediateWidget() {
    return RaisedButton(
      child: Text("同步一条数据（直接上传）"),
      onPressed: () async {
        var result = await FTMobileAgentFlutter.track(
          "flutter_list_test",{"platform": "flutter"},{"method": "直接同步"});
        print("request success: $result");
      },
    );
  }

  Widget _buildSyncListImmediateWidget() {
    return RaisedButton(
      child: Text("同步一组数据（直接上传）"),
      onPressed: () async {
        var result = await FTMobileAgentFlutter.trackList([
          TrackBean("flutter_list_test",{"platform": "flutter"}),
          TrackBean("flutter_list_test",{"platform": "flutter"},tags:{"method": "直接同步"}),
        ]);
        print("request success: $result");
      },
    );
  }

  Widget _buildSyncWidget() {
    return RaisedButton(
      child: Text("同步（后台执行）"),
      onPressed: () {
        FTMobileAgentFlutter.trackBackground(
            "flutter_list_test", {"method": "后台同步"},
            tags: {"platform": "flutter"});
      },
    );
  }

  Widget _buildFlowChartWidget() {
    return RaisedButton(
      child: Text("同步流程图数据"),
      onPressed: () {
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "开始", 1000);
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程一", 1000,
            parent: "开始");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程二", 1000,
            parent: "流程一");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "选择", 1000,
            parent: "流程二");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程三", 1000,
            parent: "选择");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程四", 1000,
            parent: "选择");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程五", 1000,
            parent: "流程三");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "流程五", 1000,
            parent: "流程四");
        FTMobileAgentFlutter.trackFlowChart(
            "flutter_agent", "trace-001", "结束", 1000,
            parent: "流程五");
      },
    );
  }

  Widget _buildBindUserWidget() {
    return RaisedButton(
      child: Text("绑定用户"),
      onPressed: () {
        FTMobileAgentFlutter.bindUser("flutter_demo", "id_001",
            extras: {"platform": "flutter"});
      },
    );
  }

  Widget _buildUnBindUserWidget() {
    return RaisedButton(
      child: Text("解绑用户"),
      onPressed: () {
        FTMobileAgentFlutter.unbindUser();
      },
    );
  }

  Widget _buildStopSDKWidget() {
    return RaisedButton(
      child: Text("停止正在执行的操作"),
      onPressed: () {
        FTMobileAgentFlutter.stopSDK();
      },
    );
  }

  void _showPermissionTip(String tip){
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("警告"),
            content: Text("你拒绝了\n$tip 权限，拒绝后将无法使用"),
            actions: <Widget>[
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  requestPermission(permissions);
                },
                child: Text("重新请求"),
              ),
              FlatButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("拒绝"),
              )
            ],
          );
        }
    );
  }

  Future<void> requestPermission(List<Permission> permission) async {
    final status = await permission.request();
    status.removeWhere((permission,state)=> state.isGranted);
    var tip = "";
    if(status.isNotEmpty){
      status.forEach((permission,state){
        state.isUndetermined;
        tip+=permission.toString()+"\n";
      });
      _showPermissionTip(tip);
    }
  }
}
