import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
const serverUrl = String.fromEnvironment("SERVER_URL");
const appId = String.fromEnvironment("APP_ID");

Future<Null> main() async {
  var onError = FlutterError.onError; //先将 onError 保存起来
  FlutterError.onError = (FlutterErrorDetails details) async {
    onError?.call(details); //调用默认的onError

  };

  runZonedGuarded((){
    runApp(MyApp());
  }, (Object error, StackTrace stack){

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
              _buildConfigWidget(),
              _buildLoggingWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigWidget() {
    return ElevatedButton(
      child: Text("设置配置"),
      onPressed: () async {
        ///配置
        FTMobileFlutter.sdkConfig(serverUrl: serverUrl, debug: true);

        FTLogger()
            .logConfig(serviceName: "flutter_agent", enableCustomLog: true);

        FTRUMManager().setConfig(rumAppId: appId);
      },
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
