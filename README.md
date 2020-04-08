
# Dataflux-SDK-flutter


# agent

基于 **ft ios android** 调用的 **plugin**

  * [使用](#使用)
    + [1. 初始化配置](#1-初始化配置)
    + [2. 上报数据 与 上报列表](#2-上报数据-与-上报列表)
    + [3. 上报流程图](#3-上报流程图)
    + [4. 主动埋点数据上报（后台运行）](#4-主动埋点数据上报后台运行)
    + [5. 用户的绑定与注销](#5-用户的绑定与注销)
    + [6. 停止 SDK 后台正在执行的操作](#6-停止-sdk-后台正在执行的操作)
    + [7. 使用示例](#7-使用示例)
  * [参数与错误码](#参数与错误码)
    + [1. Config 可配置参数](#1-config-可配置参数)
    + [2. TrackBean](#2-trackbean)
    + [3. 错误码](#3-错误码)
  * [常见问题](#常见问题)


## 使用 
```dart
import 'package:ft_mobile_agent_flutter/ft_mobile_agent.dart';
```
### 1. 初始化配置
 设置 [Config](#1-config-可配置参数) 的属性 ，启动 **SDK**。    
 
 - 方法一

 ```dart
 static void configX(Config con)
 ```

- 方法二

 ```dart
 /**
  * @method 指定初始化方法
  * @param metricsUrl FT-GateWay metrics
  * @param akId               access key ID
  * @param akSecret       access key Secret
  * @param enableLog      是否打印日志
  * @param needBindUser   是否需要绑定用户
  * @param monitorType    监控类型
  */
 static Future<void> config(String serverUrl,
      {String akId,
      String akSecret,
      String dataKitUUID,
      bool enableLog,
      bool needBindUser,
      int monitorType}) async
 ```    

### 2. 上报数据 与 上报列表
-  上报数据

   ```dart
/**
 * 上报数据
 * @param measurement      当前数据点所属的指标集
 * @param tags             自定义标签
 * @param field            自定义指标
 */
static Future<Map<dynamic, dynamic>> track(
      String measurement, Map<String, dynamic> fields,
      [Map<String, dynamic> tags]) async
   ```    

- 上报列表（[TrackBean](#2-trackbean)）

  ```dart
/**
 * 主动埋点，可多条上传。   立即上传 回调上传结果
 * @param trackList     主动埋点数据数组
 */
 static Future<Map<dynamic, dynamic>> trackList(
      List<TrackBean> list) async

  ```    

  
- 返回值    

   返回 **Map** 中 `code` 表示网络请求返回的返回码，`response` 为服务端返回的信息。
`code` 的值除了 **HTTP** 协议中规定的返回码，**FT SDK** 中额外规定了 4 种类型的 [错误码](#3-错误码)，他们是 101，102，103，104，他们分别代表的意思是网络问题、参数问题、IO异常和未知错误。
   
### 3. 上报流程图
-  方法

 ```dart
/**
 * 上报流程图
 * @param production   指标集 命名只能包含英文字母、数字、中划线和下划线，最长 40 个字符，区分大小写
 * @param traceId      标示一个流程单的唯一 ID
 * @param name         流程节点名称
 * @param duration     流程单在当前流程节点滞留时间或持续时间，毫秒为单位
 * @param parent       当前流程节点的上一个流程节点的名称，如果是流程的第一个节点，可不上报 （可选）
 * @param tags         自定义标签 （可选）
 * @param fields       自定义指标 （可选）
 */
static Future<void> trackFlowChart(
      String production, String traceId, String name, int duration,
      {String parent,
      Map<String, dynamic> tags,
      Map<String, dynamic> fields}) async

 ```

### 4. 主动埋点数据上报（后台运行）
-  方法    

  ```dart
 /**
  * 追踪自定义事件。 存储数据库，等待上传
  * @param measurement      指标（必填）
  * @param field            指标值（必填）
  * @param tags             标签（选填）
  */
static Future<void> trackBackground(
      String measurement, Map<String, dynamic> fields,
      {Map<String, dynamic> tags}) async

 ```


### 5. 用户的绑定与注销
   **FT SDK** 提供了绑定用户和注销用户的方法，[Config](#1-config-可配置参数) 属性`needBindUser` 为 `YES ` 时（默认为 `NO`），用户绑定的状态下，才会进行数据的传输。

- 绑定用户    

 ```dart
 /**
  * 绑定用户信息
  * @param name     用户名
  * @param Id       用户Id
  * @param exts     用户其他信息
  */
  static Future<void> bindUser(String name, String id,
      {Map<String, dynamic> extras}) async
  ```    
  
- 解绑用户   
 
 ```dart
 /**
  * 注销用户信息
  */
 static Future<void> unbindUser() async
  ```    

### 6. 停止 SDK 后台正在执行的操作
-  方法

  ```dart
 /**
  * 关闭 SDK 正在做的操作
  */
 static Future<void> stopSDK() async
  ```    
       
### 7. 使用示例
   [方法使用示例](https://pub.dev/packages/ft_mobile_agent_flutter#-example-tab-)


## 参数与错误码
### 1. Config 可配置参数

| 字段 | 类型 |说明|是否必须|
|:--------:|:--------:|:--------:|:--------:|
|metricsUrl|String|FT-GateWay metrics 写入地址|是|
|akId|String|access key ID| enableRequestSigning 为 true 时，必须要填|
|akSecret|String|access key Secret|enableRequestSigning 为 true 时，必须要填|
|enableLog|bool|设置是否允许打印日志|否（默认NO）|
|monitorType |int|采集数据|否|
|needBindUser|bool|是否开启绑定用户数据|否（默认NO）|

**monitorType** 可设置:    

 ```dart
 class MonitorType {
     static const int ALL = 1;
     static const int BATTERY  = 1 << 1;   // 电池总量、使用量
     static const int MEMORY   = 1 << 2;   // 内存总量、使用率
     static const int CPU      = 1 << 3;   // CPU型号、占用率
     static const int GPU      = 1 << 4;   // GPU型号、占用率
     static const int NETWORK  = 1 << 5;   // 网络的信号强度、网络速度、类型、代理
     static const int CAMERA   = 1 << 6;   // 前置/后置 像素
     static const int LOCATION = 1 << 7;   // 位置信息  eg:上海
  }    
  
 ```    

### 2. TrackBean

| 字段 | 类型 |说明|是否必须|
|:--------:|:--------:|:--------:|:--------:|
|measurement|String|当前数据点所属的指标集|是|
|tags|Map|自定义标签|否|
|fields|Map| 自定义指标|是|

### 3. 错误码   
| 字段 | 值 |说明|
|:--------:|:--------:|:--------:|
| NetWorkException |101|网络问题|
| InvalidParamsException |102|参数问题|
| FileIOException |103| 文件 IO 问题|
| UnknownException |104| 未知问题|


## 常见问题
    

- [iOS 相关](https://github.com/CloudCare/dataflux-sdk-ios#%E4%B9%9D%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)
- [Android 相关](https://github.com/CloudCare/dataflux-sdk-android#%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98)







