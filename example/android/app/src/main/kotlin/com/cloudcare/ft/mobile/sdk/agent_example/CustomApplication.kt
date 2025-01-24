package com.cloudcare.ft.mobile.sdk.agent_example

import com.ft.sdk.DeviceMetricsMonitorType
import com.ft.sdk.ErrorMonitorType
import com.ft.sdk.FTLoggerConfig
import com.ft.sdk.FTRUMConfig
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTSdk
import com.ft.sdk.FTTraceConfig
import io.flutter.app.FlutterApplication

/**
 * 如果需要统计【启动次数】和【启动时间】需要在此处添加自定义 Application
 */
class CustomApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        //原生混用初始化
//        val ftSDKConfig = FTSDKConfig.builder("http://datakit.url")
//            .setDebug(true)//是否开启Debug模式（开启后能查看调试数据）
//        FTSdk.install(ftSDKConfig)
//
//        //配置 Log
//        FTSdk.initLogWithConfig(
//            FTLoggerConfig()
//                .setEnableConsoleLog(true)
//                .setEnableLinkRumData(true)
//                .setEnableCustomLog(true)
//        )
//
//        FTSdk.initRUMWithConfig(
//            FTRUMConfig()
//                .setRumAppId("android_app_id")
//                .setEnableTraceUserAction(true)
//                .setEnableTraceUserView(true)
//                .setEnableTraceUserResource(true)
//                .setSamplingRate(1f)
//                .setExtraMonitorTypeWithError(ErrorMonitorType.ALL.value)
//                .setDeviceMetricsMonitorType(DeviceMetricsMonitorType.ALL.value)
//                .setEnableTrackAppCrash(true)
//                .setEnableTrackAppANR(true)
//        )
//
//        //配置 Trace
//        FTSdk.initTraceWithConfig(
//            FTTraceConfig()
//                .setSamplingRate(1f)
//                .setEnableAutoTrace(true)
//                .setEnableLinkRUMData(true)
//        )

    }
}