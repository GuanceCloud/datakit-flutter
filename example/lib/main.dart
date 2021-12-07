import 'dart:async';
import 'dart:io';

import 'package:agent_example/rum.dart';
import 'package:agent_example/tracing.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ft_route_observer.dart';
import 'logging.dart';

const serverUrl = String.fromEnvironment("SERVER_URL");
const appAndroidId = String.fromEnvironment("ANDROID_APP_ID");
const appIOSId = String.fromEnvironment("IOS_APP_ID");

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    //初始化 SDK
    await FTMobileFlutter.sdkConfig(
      serverUrl: serverUrl,
      debug: true,
    );
    await FTLogger()
        .logConfig(serviceName: "flutter_agent", enableCustomLog: true);
    await FTTracer().setConfig(enableLinkRUMData: true);
    await FTRUMManager().setConfig(androidAppId: appAndroidId, iOSAppId: appIOSId);

    FlutterError.onError = FTRUMManager().addFlutterError;

    runApp(MyApp());
  }, (Object error, StackTrace stack) {
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
        // 使用路由跳转时，监控页面生命周期
        FTRouteObserver(),
      ],
      routes: <String, WidgetBuilder>{
        //路由跳转
        'logging': (BuildContext context) => Logging(),
        'rum': (BuildContext context) => RUM(),
        'tracing': (BuildContext context) => Tracing(),
      },
    );
  }
}

class HomeRoute extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeRoute> {

  @override
  void initState() {
    super.initState();
    //第一个页面加载完成
    FTRUMManager().appState = AppState.run;
    if (Platform.isAndroid) {
      requestPermission([Permission.phone]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin Example App'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildBindUserWidget(),
                _buildUnBindUserWidget(),
                _buildLoggingWidget(),
                _buildTracerWidget(),
                _buildRUMWidget(),
              ],
            ),
          ),
        ));
  }

  Widget _buildBindUserWidget() {
    return ElevatedButton(
      child: Text("绑定用户"),
      onPressed: () {
        FTMobileFlutter.bindUser("flutterUser");
      },
    );
  }

  Widget _buildUnBindUserWidget() {
    return ElevatedButton(
      child: Text("解绑用户"),
      onPressed: () {
        FTMobileFlutter.unbindUser();
      },
    );
  }

  Widget _buildLoggingWidget() {
    return ElevatedButton(
      child: Text("日志输出"),
      onPressed: () {
        Navigator.pushNamed(context, "logging");
      },
    );
  }

  Widget _buildTracerWidget() {
    return ElevatedButton(
      child: Text("网络链路追踪"),
      onPressed: () {
        Navigator.pushNamed(context, "tracing");
      },
    );
  }

  Widget _buildRUMWidget() {
    return ElevatedButton(
      child: Text("RUM数据采集"),
      onPressed: () {
        Navigator.pushNamed(context, "rum");
      },
    );
  }

  void _showPermissionTip(String tip, List<Permission> permissions) {
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
      _showPermissionTip(tip, permission);
    }
  }
}
