DataFlux Flutter SDK 接口规范
# 接口目录

[1、绑定用户](#1绑定用户)

[2、解绑用户](#2解绑用户)

[3、上报流程图数据](#3上报流程图数据)

[4、主动埋点后台上传](#4主动埋点后台上传)

[5、停止SDK后台正在执行的操作](#5停止sdk后台正在执行的操作)

[6、SDK 初始化配置](#6sdk-初始化配置)

[7、主动埋点一条数据（异步回调结果）](#7主动埋点一条数据异步回调结果)

[8、主动埋点上传一组数据（异步回调结果）](#8主动埋点上传一组数据异步回调结果)
# 接口详情

## 1、绑定用户
方法名：ftBindUser

返回值：无

参数表

| 参数名  |        类型         | 是否必须 |
|:------:|:------------------:|:------:|
|  name  |       String       |   是    |
|   id   |       String       |   是    |
| extras | Map<String,Object> |   否    |

## 2、解绑用户
方法名：ftUnBindUser

返回值：无

参数：无

## 3、上报流程图数据
方法名：ftTrackFlowChart

返回值：无

参数表

|   参数名    |        类型         | 是否必须 |
|:----------:|:------------------:|:------:|
| production |       String       |   是    |
|  traceId   |       String       |   是    |
|    name    |       String       |   是    |
|  duration  |        long        |   是    |
|   parent   |       String       |   否    |
|    tags    | Map<String,Object> |   否    |
|   fields   | Map<String,Object> |   否    |


## 4、主动埋点后台上传
方法名：ftTrackBackground

返回值：无

参数表

|    参数名    |        类型         | 是否必须 |
|:-----------:|:------------------:|:------:|
| measurement |       String       |   是    |
|   fields    | Map<String,Object> |   是    |
|    tags     | Map<String,Object> |   否    |


## 5、停止SDK后台正在执行的操作
方法名：ftStopSdk

返回值：无

参数：无

## 6、SDK 初始化配置
方法名：ftConfig

返回值：无

参数表

|    参数名     |  类型   | 是否必须 |
|:------------:|:------:|:------:|
|  serverUrl   | String |   是    |
|     akId     | String |   否    |
|   akSecret   | String |   否    |
| datakitUUID  | String |   否    |
|  enableLog   |  bool  |   否    |
| needBindUser |  bool  |   否    |
| monitorType  |  int   |   否    |


## 7、主动埋点一条数据（异步回调结果）
方法名：ftTrack

返回值：Map<String, Object>

参数表

|    参数名    |         类型         | 是否必须 |
|:-----------:|:-------------------:|:------:|
| measurement |       String        |   是    |
|   fields    | Map<String, Object> |   是    |
|    tags     | Map<String, Object> |   否    |


## 8、主动埋点上传一组数据（异步回调结果）

方法名：ftTrackList

返回值：Map<String, Object>

参数表

| 参数名 |            类型            | 是否必须 |
|:-----:|:-------------------------:|:------:|
| list  | List<Map<String, Object>> |   是    |

## 9、定位回调方法

方法名：ftStartLocation

返回值：Map<String,Object>

参数表

| 参数名 | 类型  | 是否必须 |
|:---:|:---:|:----:|
|   geoKey  |  String   |    否  |



