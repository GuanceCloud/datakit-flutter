import 'dart:async';
import 'dart:io';

import 'package:agent_example/rum_page.dart';
import 'package:agent_example/tracing_page.dart';
import 'package:agent_example/view_without_route_name_page.dart';
import 'package:agent_example/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:ft_mobile_agent_flutter/ft_http_override_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ft_get_view_name.dart';
import 'logging_page.dart';

const serverUrl = String.fromEnvironment("SERVER_URL");
const appAndroidId = String.fromEnvironment("ANDROID_APP_ID");
const appIOSId = String.fromEnvironment("IOS_APP_ID");
const webViewViewUrl = String.fromEnvironment("WEB_VIEW_URL");

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await sdkInit();
    runApp(MyApp());
  }, (Object error, StackTrace stack) {
    // RUM Error: Automatically capture error data
    FTRUMManager().addError(error, stack);
  });

  print("=======config here");
}

Future<void> sdkInit() async {
  // Initialize SDK
  await FTMobileFlutter.sdkConfig(
    datakitUrl: serverUrl,
    debug: true,
    serviceName: "flutter_agent",
    // dataSyncRetryCount: 0,
    // autoSync: false,
    // customSyncPageSize: 30,
    // syncSleepTime: 100,
    compressIntakeRequests: true,
    // dbCacheLimit: 60 * 1024 * 1204,
    enableLimitWithDbSize: true,
    // dataModifier: {"device_uuid":"xxx"},
    // lineDataModifier: {"view":{"view_name":"xxx"}},
    iOSGroupIdentifiers: [
      "group.com.ft.sdk.flutter.agentExample.TodayDemo"
    ],
  );
  await FTLogger().logConfig(
    enableCustomLog: true,
    // logCacheLimitCount: 10000
  );
  // await FTMobileFlutter.registerInnerLogHandler((level, tag, message) {
  //   if (level == "E") {
  //     FTLogger()
  //         .logging("[$tag]$message", FTLogStatus.error, isSilence: true);
  //   }
  // });
  await FTTracer().setConfig(
      enableLinkRUMData: true,
      traceType: TraceType.ddTrace,
      enableAutoTrace: true); //  Trace Header in Http request
  await FTRUMManager().setConfig(
      androidAppId: appAndroidId,
      iOSAppId: appIOSId,
      enableNativeAppUIBlock: true,
      enableNativeUserAction: true,
      enableUserResource: true,
      // RUM Resource Http data capture
      isInTakeUrl: (url) {
        return false;
      },
      enableTrackNativeAppANR: true,
      enableTrackNativeCrash: true,
      errorMonitorType: ErrorMonitorType.all.value,
      deviceMetricsMonitorType: DeviceMetricsMonitorType.all.value);
  FTMobileFlutter.trackEventFromExtension(
      "group.com.ft.sdk.flutter.agentExample.TodayDemo");

  FlutterError.onError = FTRUMManager().addFlutterError;
}
// Initialization for native hybrid projects in Flutter
Future<void> sdkNativeMixInit() async {
  FTHttpOverrideConfig.global.traceHeader = true;
  FTHttpOverrideConfig.global.traceResource = true;
  FlutterError.onError = FTRUMManager().addFlutterError;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      navigatorObservers: [
        // RUM View: Monitor page lifecycle when using route navigation
        // FTRouteObserver(),
        // RUM View: routeFilter to filter pages that do not need to be monitored
        // FTRouteObserver(routeFilter: (Route? route, Route? previousRoute) {
        //   if (route is DialogRoute ||
        //       previousRoute is DialogRoute ||
        //       route is PopupRoute ||
        //       previousRoute is PopupRoute) {
        //     return true;
        //   }
        //   return false;
        // }),
        // RUM View: Filter DialogRoute and PopRoute type components
        FTDialogRouteFilterObserver(
            filterOnlyNoSettingName: false, filterPopRoute: true)
      ],
      routes: <String, WidgetBuilder>{
        // Route navigation
        'logging': (BuildContext context) => LoggingPage(),
        'rum': (BuildContext context) => RUMPage(),
        'tracing_custom': (BuildContext context) => CustomTracingPage(),
        'tracing_auto': (BuildContext context) => AutoTracingPage(),
        'webview': (BuildContext context) => WebViewPage(url: webViewViewUrl),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      requestPermission(
          [Permission.phone]);
    }
    // else if (Platform.isIOS) {
    //   requestPermission([Permission.camera, Permission.photos]);
    // }

    WidgetsBinding.instance.addObserver(this); // Add observer
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Extension sync to cache
      FTMobileFlutter.trackEventFromExtension(
          "group.com.ft.sdk.flutter.agentExample.TodayDemo");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this); // Remove observer
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
                _buildConfigRouteSettingWidget(),
                _buildLazyInitWidget(),
                _buildFlushSyncDataWidget(),
                _buildDialogWidget(),
                _buildPopRouteWidget(),
                _buildImagePicker(),
                _buildGlobalContext(),
                _buildCleanAllData()
              ],
            ),
          ),
        ));
  }

  Widget _buildLazyInitWidget() {
    return ElevatedButton(
      child: Text("Delayed SDK Initialization"),
      onPressed: () {
        sdkInit();
      },
    );
  }

  Widget _buildFlushSyncDataWidget() {
    return ElevatedButton(
      child: Text("Manual Data Sync"),
      onPressed: () {
        FTMobileFlutter.flushSyncData();
      },
    );
  }

  Widget _buildBindUserWidget() {
    return ElevatedButton(
      child: Text("Bind User"),
      onPressed: () {
        //RUM user data binding
        FTMobileFlutter.bindRUMUserData("flutterUserId",
            userEmail: "flutter@email.com",
            userName: "flutterUser",
            ext: {"ft_key": "ft_value"});
      },
    );
  }

  Widget _buildUnBindUserWidget() {
    return ElevatedButton(
      child: Text("Unbind User"),
      onPressed: () {
        //RUM user data unbinding
        FTMobileFlutter.unbindRUMUserData();
      },
    );
  }

  Widget _buildLoggingWidget() {
    return ElevatedButton(
      child: Text("Log Output"),
      onPressed: () {
        Navigator.pushNamed(context, "logging");
      },
    );
  }

  Widget _buildTracerCustomWidget() {
    return ElevatedButton(
      child: Text("Network Tracing (Custom)"),
      onPressed: () async {
        // Check if global setting exists
        bool hasSet = HttpOverrides.current != null;
        if (hasSet) {
          // Remove network data capture
          HttpOverrides.global = null;
        }
        await Navigator.pushNamed(context, "tracing_custom");

        if (hasSet) {
          // Restore network capture
          HttpOverrides.global = FTHttpOverrides();
        }
      },
    );
  }

  Widget _buildTracerAutoWidget() {
    return ElevatedButton(
      child: Text("Network Tracing (Auto)"),
      onPressed: () {
        Navigator.pushNamed(context, "tracing_auto");
      },
    );
  }

  Widget _buildRUMWidget() {
    return ElevatedButton(
      child: Text("RUM Data Collection"),
      onPressed: () {
        Navigator.pushNamed(context, "rum");
      },
    );
  }

  Widget _buildNoNavigatorObserversWidget() {
    return ElevatedButton(
      child: Text("No Route Name Set"),
      onPressed: () {
        Navigator.of(context).push(
          FTMaterialPageRoute(builder: (context) => new NoRouteNamePage()),
        );
      },
    );
  }

  Widget _buildConfigRouteSettingWidget() {
    return ElevatedButton(
      child: Text("Set name property in RouteSetting"),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => new NoRouteNamePage(),
              settings: RouteSettings(name: "RouteSettingName")),
        );
      },
    );
  }

  Widget _buildDialogWidget() {
    return ElevatedButton(
      child: Text("About Dialog"),
      onPressed: () {
        showAboutDialog(
            context: context, routeSettings: RouteSettings(name: "About"));
      },
    );
  }

  Widget _buildPopRouteWidget() {
    return ElevatedButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 200,
                color: Colors.amber,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Modal BottomSheet'),
                      ElevatedButton(
                        child: const Text('Close BottomSheet'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Text("BottomSheet"));
  }

  Widget _buildImagePicker() {
    return ElevatedButton(
        onPressed: () async {
          final ImagePicker picker = ImagePicker();
          FTRUMManager().startAction("Image Picker", "image_pick");
          final XFile? files =
              await picker.pickImage(source: ImageSource.gallery);
        },
        child: Text("Image Picker"));
  }

  Widget _buildGlobalContext() {
    return ElevatedButton(
        onPressed: () async {
          FTMobileFlutter.appendGlobalContext({"global_key": "global_value"});
          FTMobileFlutter.appendLogGlobalContext({"log_key": "log_value"});
          FTMobileFlutter.appendRUMGlobalContext({"rum_key": "rum_value"});
        },
        child: Text("Add Dynamic Tags"));
  }

  Widget _buildCleanAllData() {
    return ElevatedButton(
        onPressed: () async {
          FTMobileFlutter.clearAllData();
        },
        child: Text("Clear Cache"));
  }

  void _showPermissionTip(String tip, List<Permission> permissions) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("You have denied\n$tip permission, which will make the feature unavailable."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  requestPermission(permissions);
                },
                child: Text("Request Again"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Deny"),
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
