import 'dart:async';
import 'dart:io';

import 'package:agent_example/rum.dart';
import 'package:agent_example/tracing.dart';
import 'package:agent_example/view_without_route_name.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ft_get_view_name.dart';
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
      serviceName: "flutter_agent",
      iOSGroupIdentifiers: [
        "group.com.cloudcare.ft.mobile.sdk.agentExample.TodayDemo"
      ],
    );
    await FTLogger()
        .logConfig( enableCustomLog: true);
    await FTTracer().setConfig(
        enableLinkRUMData: true,
        traceType: TraceType.ddTrace,
        enableAutoTrace: true);//  Trace 在 Http 请求 Trace Header
    await FTRUMManager().setConfig(
        androidAppId: appAndroidId,
        iOSAppId: appIOSId,
        enableNativeAppUIBlock: true,
        enableNativeUserAction: true,
        enableUserResource: true,// RUM Resource Http 数据抓取
        errorMonitorType: ErrorMonitorType.all.value,
        deviceMetricsMonitorType: DeviceMetricsMonitorType.all.value);
    FTMobileFlutter.trackEventFromExtension(
        "group.com.cloudcare.ft.mobile.sdk.agentExample.TodayDemo");

    FlutterError.onError = FTRUMManager().addFlutterError;

    runApp(MyApp());
  }, (Object error, StackTrace stack) {
    //RUM Error： 记录 自动抓取 error 数据
    FTRUMManager().addError(error, stack);
  });
  print("=======config here");
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
        //RUM View： 使用路由跳转时，监控页面生命周期
        FTRouteObserver(),
      ],
      routes: <String, WidgetBuilder>{
        //路由跳转
        'logging': (BuildContext context) => Logging(),
        'rum': (BuildContext context) => RUM(),
        'tracing_custom': (BuildContext context) => CustomTracing(),
        'tracing_auto': (BuildContext context) => AutoTracing(),
      },
    );
  }
}

class HomeRoute extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeRoute> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      requestPermission([Permission.phone]);
    }


    WidgetsBinding.instance?.addObserver(this); //添加观察者

    //RUM View：休眠与唤醒事件
    //添加应用休眠和唤醒监听
    FTLifeRecycleHandler().initObserver();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Extension 同步至缓存
      FTMobileFlutter.trackEventFromExtension(
          "group.com.cloudcare.ft.mobile.sdk.agentExample.TodayDemo");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    //RUM View：休眠与唤醒事件
    FTLifeRecycleHandler().removeObserver();
    WidgetsBinding.instance?.removeObserver(this); //添加观察者
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
                _buildTracerCustomWidget(),
                _buildTracerAutoWidget(),
                _buildRUMWidget(),
                _buildNoNavigatorObserversWidget(),
              ],
            ),
          ),
        ));
  }

  Widget _buildBindUserWidget() {
    return ElevatedButton(
      child: Text("绑定用户"),
      onPressed: () {
        //RUM 用户数据绑定
        FTMobileFlutter.bindRUMUserData("flutterUserId",
            userEmail: "flutter@email.com",
            userName: "flutterUser",
            ext: {"ft_key": "ft_value"});
      },
    );
  }

  Widget _buildUnBindUserWidget() {
    return ElevatedButton(
      child: Text("解绑用户"),
      onPressed: () {
        //RUM 用户数据解绑
        FTMobileFlutter.unbindRUMUserData();
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

  Widget _buildTracerCustomWidget() {
    return ElevatedButton(
      child: Text("网络链路追踪(自定义)"),
      onPressed: () async {

        //判断是否全局设置
        bool hasSet = HttpOverrides.current != null;
        if (hasSet) {
          //移除网络数据抓取
          HttpOverrides.global = null;
        }
        await Navigator.pushNamed(context, "tracing_custom");

        if (hasSet) {
          //恢复网络抓取
          HttpOverrides.global = FTHttpOverrides();
        }
      },
    );
  }

  Widget _buildTracerAutoWidget() {
    return ElevatedButton(
      child: Text("网络链路追踪(自动)"),
      onPressed: () {
        Navigator.pushNamed(context, "tracing_auto");
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

  Widget _buildNoNavigatorObserversWidget() {
    return ElevatedButton(
      child: Text("不设置 Route Name"),
      onPressed: () {
        Navigator.of(context).push(
          FTMaterialPageRoute(builder: (context) => new NoRouteNamePage()),
        );
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
