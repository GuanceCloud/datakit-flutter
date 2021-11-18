DataFlux Flutter SDK 接口规范
# 接口目录

[1、SDK 初始化配置](#1SDK-初始化配置)

[2、绑定用户](#2绑定用户)

[3、解绑用户](#3解绑用户)

[4、Logging 初始化配置](#4Logging-初始化配置)

[5、日志写入](#5日志写入)

[6、Tracing 初始化配置](#6Tracing-初始化配置)

[7、获取 Tracing 请求头](#7获取-Tracing-请求头)

[8、Tracing 数据写入](#8Tracing-数据写入)

[9、RUM 初始化配置](#9RUM-初始化配置)

[10、RUM: Action](#10RUM:-Action)

[11、RUM: View Start](#11RUM:-View-Start)

[12、RUM: View Stop](#12RUM:-View-Stop)

[13、RUM: Error](#13RUM:-Error)

[14、RUM: Resource Start](#14RUM:-Resource-Start)

[15、RUM: Resource Stop](#15RUM:-Resource-Stop)


# 接口详情
## 1、SDK 初始化配置
方法名：ftLogConfig

返回值：无

参数表

|    参数名     |  类型   | 是否必须 |
|:------------:|:------:|:------:|
|  serverUrl   | String |   是    |
|     debug    | bool   |   否    |
| datakitUUID  | String |   否    |
|  env         |  Int   |   否    |
| useOAID      |  bool  |   否    |

## 2、绑定用户
方法名：ftBindUser

返回值：无

参数表

| 参数名  |        类型         | 是否必须 |
|:------:|:------------------:|:------:|
|  userId|       String       |   是    |

## 3、解绑用户
方法名：ftUnBindUser

返回值：无

参数：无



## 4、Logging 初始化配置
方法名：ftLogConfig

返回值：无

参数表

|    参数名    |         类型         | 是否必须 |
|:-----------:|:-------------------:|:------:|
| serviceName |       String        |   否    |
|   logType   | [Int] |   否    |
|  logCacheDiscard | bool           |   否   |
|sampleRate   |      double            | 否        |
|enableCustomLog|   bool            | 否       |
|enableLinkRumData|   bool          | 否       |

## 5、日志写入
方法名：ftLogging
返回值：无
参数表

|    参数名    |         类型         | 是否必须 |
|:-----------:|:-------------------:|:------:|
| content |       String        |  是    |
|   status   | Int |   是    |

## 6、Tracing 初始化配置

方法名：ftTraceConfig

返回值：无

参数表

| 参数名 |            类型            | 是否必须 |
|:-----:|:-------------------------:|:------:|
| sampleRate  | double |   否    |
| serviceName  | String |   否    |
| traceType  | enum |   否    |
| enableLinkRUMData  | bool |   否    |


## 7、获取 Tracing 请求头
方法名：ftTraceGetHeader

返回值：Map<String,String>

参数表

| 参数名 |            类型            | 是否必须 |
|:-----:|:-------------------------:|:------:|
| key  | String |  是    |
| url  | String |   是    |

## 8、Tracing 数据写入
方法名：ftTrace

返回值：Map<String, Object>

参数表

| 参数名 |            类型            | 是否必须 |
|:-----:|:-------------------------:|:------:|
| key  | String |  是    |
| content | String |   是    |
| operationName | String |   是    |
| isError | bool |   是    |

## 9、RUM 初始化配置

方法名：ftRumConfig

返回值：Map<String,Object>

参数表

| 参数名 | 类型  | 是否必须 |
|:---:|:---:|:----:|
|   rumAppId  |  String   |    是  |
|   sampleRate  |  double   |    否  |
|   enableUserAction  |  bool   |    否  |
|   monitorType  |  enum   |    否  |
|   globalContext  |  Map   |    否  |

## 10、RUM: Action
方法名：ftRumAddAction

返回值：无

参数表

|     参数名     |   类型   | 是否必须 |
|:-----------:|:------:|:----:|
|   actionName    | String |  是   |
|  actionType  |  String  |  是   |

## 11、RUM: View Start

方法名：ftRumStartView

返回值：无

参数表

|     参数名     |   类型   | 是否必须 |
|:-----------:|:------:|:----:|
|   viewName    | String |  是   |
|  viewReferer  |  String  |  是   |

## 12、RUM: View Stop

方法名：ftRumStopView

返回值：无

参数表


## 13、RUM: Error

方法名：ftRumAddError

返回值：无

参数表

|     参数名     |   类型   | 是否必须 |
|:-----------:|:------:|:----:|
|   stack    | String |  是   |
|  message  |  String  |  是   |
|  appState  |  Int  |  是   |


## 14、RUM: Resource Start

方法名：ftRumStartResource

返回值：无

参数表

|     参数名     |   类型   | 是否必须 |
|:-----------:|:------:|:----:|
|   key    | String |  是   |

## 15、RUM: Resource Stop

方法名：ftRumStopResource

返回值：无

参数表

|     参数名     |   类型   | 是否必须 |
|:-----------:|:------:|:----:|
|   key    | String |  是   |
|  url  |  String  |  是   |
|  resourceMethod  |  String  |  是   |
|  requestHeader  |  Map<String, dynamic>   |  是   |
|  responseHeader  |  Map<String, dynamic>  |  否   |
|  resourceStatus  |  Int  |  否   |
|  responseBody  |  String  |  否   |
|  spanID  |  String  |  否   |
|  traceID  |  String  |  否   |
