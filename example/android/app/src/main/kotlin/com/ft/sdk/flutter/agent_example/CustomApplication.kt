package com.ft.sdk.flutter.agent_example

import io.flutter.app.FlutterApplication

/**
 * If you need to count [startup count] and [startup time], you need to add a custom Application here
 */
class CustomApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        // Native hybrid initialization
//        val ftSDKConfig = FTSDKConfig.builder("http://datakit.url")
//            .setDebug(true)// Whether to enable Debug mode (enable to view debug data)
//        FTSdk.install(ftSDKConfig)
//
//        // Configure Log
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
//        // Configure Trace
//        FTSdk.initTraceWithConfig(
//            FTTraceConfig()
//                .setSamplingRate(1f)
//                .setEnableAutoTrace(true)
//                .setEnableLinkRUMData(true)
//        )

    }
}