import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
//      platformVersion = await FTMobileAgentFlutter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
              FlatButton(
                child: Text("同步"),
                onPressed: () async {
                  FTMobileAgentFlutter.config(
                      "http://10.100.64.106:19457/v1/write/metrics",
                      "accid",
                      "accsk");
                  var success = await FTMobileAgentFlutter.trackList([
                    {
                      "measurement": "flutter_list_test",
                      "fields": {"test": "value1"},
                      "tags":{"test":"test"}
                    },
                  ]);
                  print("request success: $success");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
