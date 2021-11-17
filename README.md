
# Dataflux-SDK-flutter


# agent

基于 **ft ios android** 调用的 **plugin**

  * [使用](#使用)
  * [常见问题](#常见问题)

## 使用 

```dart
import 'package:ft_mobile_agent_flutter/ft_mobile_agent.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();

  //初始化 SDK
  await FTMobileFlutter.sdkConfig(serverUrl: serverUrl, debug: true,);
  await FTLogger()
      .logConfig(serviceName: "flutter_agent", enableCustomLog: true);
  await FTTracer().setConfig(enableLinkRUMData: true);
  await FTRUMManager().setConfig(rumAppId: appId,enableUserAction: true);
 
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
```

### SDK 初始化

1. 初始化

   ```dart
   /**
    * serverUrl           数据上报地址
    * useOAID             
    * debug               是否允许 SDK 打印 Debug 日志
    * datakitUUID         请求HTTP请求头X-Datakit-UUID 数据采集端 
    * envType             环境
   */
   Future<void> sdkConfig(
         {required String serverUrl,
         bool? useOAID,
         bool? debug,
         String? datakitUUID,
         EnvType? envType}) async 
   ```

   

2. 绑定用户

   ```dart
    /**
    * userId           用户Id 
   */
   static Future<void> bindUser(String userId) async 
   ```

   

3. 取消绑定

   ```dart
   static Future<void> unbindUser() async 
   ```

   

### Logging

1. Logging 初始化

   ```dart
   /**
    * sampleRate           采集率
    * serviceName          日志所属业务或服务的名称
    * enableLinkRumData    是否将 logger 数据与 rum 关联
    * discardStrategy      日志废弃策略
    * logLevelFilters      采集自定义日志的状态数组
   */
   Future<void> logConfig(
         {double? sampleRate,  
         String? serviceName,
         bool? enableLinkRumData,
         bool? enableCustomLog,
         FTLogCacheDiscard? discardStrategy,
         List<FTLogStatus>? logLevelFilters}) async
   ```

   

2. 日志上报

   ```dart
   /**
    * content           日志内容，可为json字符串
    * status            事件等级状态
   */ 
   Future<void> logging(String content, FTLogStatus status) async 
   ```

   

### Tracing

1. Tracing 初始化

   ```dart
   /**
    * sampleRate           采集率
    * serviceName          所属业务或服务的名称
    * traceType            网络请求信息采集时 使用链路追踪类型
    * enableLinkRUMData
   */ 
   Future<void> setConfig({double? sampleRate,
       String? serviceName,
       TraceType? traceType,
       bool? enableLinkRUMData}) async
   ```

   

2. Tracing 获取请求头

   ```dart
   /**
    * key           请求唯一标识
    * url           请求url
   */  
   Future<Map<String, String>> getTraceHeader(String key, String url) async
   ```

3. Tracing 数据添加

   ```dart
   /**
    * key            请求唯一标识
    * url            请求url
    * httpMethod     请求方法
    * requestHeader  请求头
    * statusCode     响应状态码
    * responseHeader 响应头
    * errorMessage   请求失败信息
   */    
   Future<void> addTrace({
       required String key,
       required Uri url,
       required String httpMethod,
       required Map<String, dynamic>requestHeader,
       int? statusCode,
       Map<String, dynamic>? responseHeader,
       String? errorMessage,
     }) async  
   ```


### RUM

1. Rum 初始化

   ```dart
   /**
    * rumAppId           应用唯一ID，在DataFlux控制台上面创建监控时自动生成
    * sampleRate         采集率
    * enableUserAction   设置是否追踪用户操作     
    * monitorType        TAG 中的设备信息
    * globalContext      全局 TAG
   */    
   Future<void> setConfig(
         {required String rumAppId,
         double? sampleRate,
         bool? enableUserAction,
         MonitorType? monitorType,
         Map? globalContext}) async 
   ```

   

2. View

   * 页面开启

     ```dart
     /**
      * viewName           页面名称
      * viewReferer        页面父视图
     */    
     Future<void> starView(String viewName, String viewReferer) async
     ```

   * 页面关闭

     ```dart
     Future<void> stopView() async
     ```

     

3. Action

   ```dart
   /**
    * actionName         事件名称
    * actionType         事件类型
   */  
   Future<void> startAction(String actionName, String actionType) async
   ```

   

4. Resource

   * 请求开始

     ```dart
     /**
      * key               请求唯一标识
     */  
     Future<void> startResource(String key) async 
     ```

   * 请求结束

     ```dart
     /**
      * key               请求唯一标识
      * url               请求url
      * httpMethod        请求方法
      * requestHeader     请求头
      * responseHeader    响应头
      * responseBody      请求返回数据
      * resourceStatus    响应状态码
     */  
     Future<void> stopResource(
           {required String key,
           required String url,
           required String httpMethod,
           required Map requestHeader,
           Map? responseHeader,
           String? responseBody = "",
           int? resourceStatus}) async
     ```

     

5. Error

   ```dart
   ///Flutter框架异常捕获
     Future<void> addFlutterError(FlutterErrorDetails error) async 
       
   ///其它异常捕获与日志收集
     Future<void> addError(Object obj, StackTrace stack) async
   
   ///自定义 Error
   /**
    * stack           堆栈信息
    * message         错误信息
   */  
     Future<void> addCustomError(String stack, String message) async 
   ```




## 常见问题


- [iOS 相关](https://github.com/CloudCare/dataflux-sdk-ios#%E4%B9%9D%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)
- [Android 相关](https://github.com/CloudCare/dataflux-sdk-android#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)







