@[TOC](DataFlux Flutter SDK 接口规范)
# 接口目录
## 1、绑定用户
    方法名：ftBindUser
    
    参数1：name        类型：String
    参数2：id          类型：String
    参数3：extras      类型：Map<String,Object>
    
    返回值：无
## 2、解绑用户
	方法名：ftUnBindUser
	
	参数：无
	返回值：无

## 3、上报流程图数据
	方法名：ftTrackFlowChart
	
	参数1：production          类型：String
	参数2：traceId             类型：String
	参数3：name                类型：String
	参数4：parent              类型：String
	参数5：duration            类型：long
	参数6：tags                类型：Map<String,Object>
	参数7：fields              类型：Map<String,Object>
	
	返回值：无

## 4、主动埋点后台上传
	方法名：ftTrackBackground
	
	参数1：measurement         类型：String
	参数2：tags                类型：Map<String,Object>
	参数3：fields              类型：Map<String,Object>	
	
	返回值：无

## 5、停止SDK后台正在执行的操作
	方法名：ftStopSdk
	参数：无
	返回值：无
