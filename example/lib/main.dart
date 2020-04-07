import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
              _buildSyncWidget(),
              _buildFlowChartWidget(),
              _buildBindUserWidget(),
              _buildUnBindUserWidget(),
              _buildStopSDKWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigWidget() {
    return RaisedButton(
      child: Text("设置配置"),
      onPressed: () {
        /// 配置方法一
        FTMobileAgentFlutter.configX(
            Config("http://10.100.64.106:19457/v1/write/metrics")
                .setAK("accid", "accsk")
                .setDataKit("flutter_datakit")
                .setEnableLog(true)
                .setNeedBindUser(false)
                .setMonitorType(MonitorType.BATTERY | MonitorType.NETWORK)
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
      child: Text("同步（直接上传）"),
      onPressed: () async {
        var result = await FTMobileAgentFlutter.trackList([
          {
            "measurement": "flutter_list_test",
            "fields": {"platform": "flutter"},
            "tags": {"method": "直接同步"}
          },
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
            fields: {"platform": "flutter"});
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
}
