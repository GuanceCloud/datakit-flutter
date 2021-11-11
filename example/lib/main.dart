import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

const serverUrl = String.fromEnvironment("SERVER_URL");
const appId = String.fromEnvironment("APP_ID");
Future<Null> main() async {
  //初始化 SDK
  FTMobileFlutter.sdkConfig(serverUrl: serverUrl, debug: true);
  FTLogger()
      .logConfig(serviceName: "flutter_agent", enableCustomLog: true);
  FTTracer().setConfig(enableLinkRUMData: true);
  FTRUMManager().setConfig(rumAppId: appId);
  FTRUMManager().appState = AppState.startup;
  //先将 onError 保存起来
  var onError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) async {
    //调用默认的onError
    onError?.call(details);
    //RUM 记录 error 数据
    FTRUMManager().addFlutterError(details);
  };

  runZonedGuarded((){
    runApp(MyApp());
  }, (Object error, StackTrace stack){
    //RUM 记录 error 数据
    FTRUMManager().addError(error, stack);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeRoute(),
      navigatorObservers: [
        FTRouteObserver(),
      ],
    );
  }
}


class HomeRoute extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeRoute> {
  var permissions = [Permission.storage, Permission.phone];
  var locationState = "";
  var locationStateGeo = "";

  @override
  void initState() {
    super.initState();
    //第一个页面加载完成
    FTRUMManager().appState = AppState.run;
    if (Platform.isAndroid) {
      requestPermission(permissions);
    } else if (Platform.isIOS) {
      requestPermission([Permission.location]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildLoggingWidget(),
              _buildTracerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoggingWidget() {
    return ElevatedButton(
      child: Text("日志输出"),
      onPressed: () {
        FTLogger().logging("log content", FTLogStatus.info);
      },
    );
  }
  Widget _buildTracerWidget() {
    return ElevatedButton(
      child: Text("网络链路追踪"),
      onPressed: () {
      },
    );
  }
  Widget _buildRUMWidget() {
    return ElevatedButton(
      child: Text("RUM数据采集"),
      onPressed: () {

      },
    );
  }
  void _showPermissionTip(String tip) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("警告"),
            content: Text("你拒绝了\n$tip 权限，拒绝后将无法使用"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  requestPermission(permissions);
                },
                child: Text("重新请求"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("拒绝"),
              )
            ],
          );
        });
  }

  Future<void> requestPermission(List<Permission> permission) async {
    final status = await permission.request();
    status.removeWhere((permission, state) => state.isGranted);
    var tip = "";
    if (status.isNotEmpty) {
      status.forEach((permission, state) {
        state.isGranted;
        tip += permission.toString() + "\n";
      });
      _showPermissionTip(tip);
    }
  }
}
