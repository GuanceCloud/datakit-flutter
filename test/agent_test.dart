import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ft_mobile_agent_flutter');
  TestWidgetsFlutterBinding.ensureInitialized();
  const METHOD_CONFIG = "ftConfig";
  const METHOD_TRACK = "ftTrack";
  const METHOD_TRACK_LIST = "ftTrackList";
  const METHOD_TRACK_BACKGROUND = "ftTrackBackground";
  const METHOD_BIND_USER = "ftBindUser";
  const METHOD_UNBIND_USER = "ftUnBindUser";
  const METHOD_STOP_SDK = "ftStopSdk";
  const METHOD_START_LOCATION = "ftStartLocation";
  dynamic resultCode;
  setUp(() async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case METHOD_CONFIG:
        case METHOD_TRACK_BACKGROUND:
        case METHOD_BIND_USER:
        case METHOD_UNBIND_USER:
        case METHOD_STOP_SDK:
          resultCode = true;
          return null;
        case METHOD_TRACK:
        case METHOD_TRACK_LIST:
        case METHOD_START_LOCATION:
          return resultCode;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  /// 测试配置
  test("config", () async {
    FTMobileAgentFlutter.configX(
        Config("http://10.100.64.106:19457")
            .setAK("accid", "accsk")
            .setDataKit("flutter_datakit")
            .setEnableLog(true)
            .setNeedBindUser(false)
            .setToken("tkn_4c4f9f29f39c493199bb5abe7df6af21")
            .setMonitorType(MonitorType.BATTERY | MonitorType.NETWORK)
    );
    expect(resultCode, isTrue);
  });

  /// 测试异步上传埋点数据
  test('trackOneData', () async {
    resultCode = {
      "code": "200",
      "response": {"code": 200, "errorCode": "", "message": ""}
    };
    var result = await FTMobileAgentFlutter.track(
        'flutter_list_test', {'platform': 'flutter'}, {'method': '直接同步'});
    expect(result, resultCode);
  });

  /// 测试异步上传埋点数据
  test('trackList', () async {
    resultCode = {
      "code": "200",
      "response": {"code": 200, "errorCode": "", "message": ""}
    };
    var arguments = [
      TrackBean("flutter_list_test",{"platform": "flutter"}),
      TrackBean("flutter_list_test",{"platform": "flutter"},tags:{"method": "直接同步"}),
    ];
    var result = await FTMobileAgentFlutter.trackList(arguments);
    expect(result, resultCode);
  });


  /// 测试主动后台上报
  test("trackBackground",() async{
    FTMobileAgentFlutter.trackBackground('flutter_list_test',{'platform': 'flutter'},tags:{'method': '直接同步'});
    expect(resultCode, isTrue);
  });

  /// 测试绑定用户
  test("bindUser", () async {
    FTMobileAgentFlutter.bindUser('flutter_list_test', 'flutter',
        extras: {'method': '直接同步'});
    expect(resultCode, isTrue);
  });

  /// 测试解绑用户
  test("unbindUser", () async {
    FTMobileAgentFlutter.unbindUser();
    expect(resultCode, isTrue);
  });

  /// 测试停止SDK操作
  test("stopSDK", () async {
    FTMobileAgentFlutter.stopSDK();
    expect(resultCode, isTrue);
  });

  /// 测试定位
  test('startLocation', () async {
    resultCode = {
      "code": 0,
      "message": ""
    };
    var result = await FTMobileAgentFlutter.startLocation();
    expect(result, resultCode);
  });
}
