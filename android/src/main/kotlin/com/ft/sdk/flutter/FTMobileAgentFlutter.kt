package com.ft.sdk.flutter

import android.app.Application
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
import androidx.annotation.VisibleForTesting
import com.ft.sdk.DBCacheDiscard
import com.ft.sdk.DataModifier
import com.ft.sdk.DetectFrequency
import com.ft.sdk.FTLogger
import com.ft.sdk.FTLoggerConfig
import com.ft.sdk.FTRUMConfig
import com.ft.sdk.FTRUMGlobalManager
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTSdk
import com.ft.sdk.FTTraceConfig
import com.ft.sdk.FTTraceManager
import com.ft.sdk.InnerClassProxy
import com.ft.sdk.LineDataModifier
import com.ft.sdk.LogCacheDiscard
import com.ft.sdk.RUMCacheDiscard
import com.ft.sdk.SyncPageSize
import com.ft.sdk.TraceType
import com.ft.sdk.garble.bean.AppState
import com.ft.sdk.garble.bean.ErrorType
import com.ft.sdk.garble.bean.NetStatusBean
import com.ft.sdk.garble.bean.ResourceParams
import com.ft.sdk.garble.bean.Status
import com.ft.sdk.garble.bean.UserData
import com.ft.sdk.garble.utils.Constants
import com.ft.sdk.garble.utils.LogUtils
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** AgentPlugin */
class FTMobileAgentFlutter : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var application: Application
    private var viewGroup: ViewGroup? = null

    private var handler: Handler? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ft_mobile_agent_flutter")
        channel.setMethodCallHandler(this)
        application = flutterPluginBinding.applicationContext as Application
        handler = Handler(Looper.getMainLooper())
//        setChancelDebug(true)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        try {
            val activity = binding.activity
            val temp = activity.window.decorView.rootView
            if (temp is ViewGroup) {
                viewGroup = temp
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        const val LOG_TAG = "${Constants.LOG_TAG_PREFIX}FTMobileAgentFlutter"
        const val METHOD_CONFIG = "ftConfig"
        const val METHOD_FLUSH_SYNC_DATA = "ftFlushSyncData"

        const val METHOD_BIND_USER = "ftBindUser"
        const val METHOD_UNBIND_USER = "ftUnBindUser"
        const val METHOD_ENABLE_ACCESS_ANDROID_ID = "ftEnableAccessAndroidID"

        const val METHOD_APPEND_GLOBAL_CONTEXT = "ftAppendGlobalContext"
        const val METHOD_APPEND_RUM_GLOBAL_CONTEXT = "ftAppendRUMGlobalContext"
        const val METHOD_APPEND_LOG_GLOBAL_CONTEXT = "ftAppendLogGlobalContext"
        const val METHOD_CLEAR_ALL_DATA = "ftClearAllData"

        const val METHOD_LOG_CONFIG = "ftLogConfig"
        const val METHOD_LOGGING = "ftLogging"

        const val METHOD_RUM_CONFIG = "ftRumConfig"
        const val METHOD_RUM_START_ACTION = "ftRumStartAction"
        const val METHOD_RUM_ADD_ACTION = "ftRumAddAction"
        const val METHOD_RUM_CREATE_VIEW = "ftRumCreateView"
        const val METHOD_RUM_START_VIEW = "ftRumStartView"
        const val METHOD_RUM_STOP_VIEW = "ftRumStopView"
        const val METHOD_RUM_ADD_ERROR = "ftRumAddError"
        const val METHOD_RUM_START_RESOURCE = "ftRumStartResource"
        const val METHOD_RUM_STOP_RESOURCE = "ftRumStopResource"
        const val METHOD_RUM_ADD_RESOURCE = "ftRumAddResource"

        const val METHOD_TRACE_CONFIG = "ftTraceConfig"
        const val METHOD_GET_TRACE_HEADER = "ftTraceGetHeader"
        const val METHOD_SET_INNER_LOG_HANDLER = "ftSetInnerLogHandler"
        const val METHOD_INVOKE_INNER_LOG = "ftInvokeInnerLog"

        const val KEY_DATAKIT_URL = "datakitUrl"
        const val KEY_DATAWAY_URL = "datawayUrl"
        const val KEY_CLI_TOKEN = "cliToken"
        const val KEY_DEBUG = "debug"
        const val KEY_SERVICE_NAME = "serviceName"
        const val KEY_DATA_SYNC_RETRY_COUNT = "dataSyncRetryCount"
        const val KEY_ENV_TYPE = "env"
        const val KEY_GLOBAL_CONTEXT = "globalContext"
        const val KEY_ENABLE_ACCESS_ANDROID_ID = "enableAccessAndroidID"
        const val KEY_AUTO_SYNC = "autoSync"
        const val KEY_SYNC_PAGE_SIZE = "syncPageSize"
        const val KEY_CUSTOM_SYNC_PAGE_SIZE = "customSyncPageSize"
        const val KEY_SYNC_SLEEP_TIME = "syncSleepTime"
        const val KEY_COMPRESS_INTAKE_REQUESTS = "compressIntakeRequests"
        const val KEY_ENABLE_DATA_INTEGER_COMPATIBLE = "enableDataIntegerCompatible"
        const val KEY_ENABLE_LIMIT_WITH_DB_SIZE = "enableLimitWithDbSize"
        const val KEY_DB_CACHE_LIMIT = "dbCacheLimit"
        const val KEY_DB_CACHE_DISCARD = "dbCacheDiscard"
        const val KEY_DATA_MODIFIER = "dataModifier"
        const val KEY_LINE_DATA_MODIFIER = "lineDataModifier"
        const val KEY_ENABLE_REMOTE_CONFIGURATION = "enableRemoteConfiguration"
        const val KEY_REMOTE_CONFIG_MINI_UPDATE_INTERVAL = "remoteConfigMiniUpdateInterval"
        const val KEY_ENABLE_TRACE_WEBVIEW = "enableTraceWebView"
        const val KEY_ALLOW_WEBVIEW_HOST = "allowWebViewHost"
        const val KEY_PKG_INFO = "pkgInfo"

        const val KEY_SAMPLE_RATE = "sampleRate"
        const val KEY_TRACE_TYPE = "traceType"
        const val KEY_ENABLE_LINK_RUM_DATA = "enableLinkRUMData"
        const val KEY_ENABLE_NATIVE_AUTO_TRACE = "enableNativeAutoTrace"

        const val KEY_RUM_APP_ID = "rumAppId"
        const val KEY_SESSION_ON_ERROR_SAMPLE_RATE = "sessionOnErrorSampleRate"
        const val KEY_ENABLE_USER_ACTION = "enableUserAction"
        const val KEY_ENABLE_USER_VIEW = "enableUserView"
        const val KEY_ENABLE_USER_VIEW_IN_FRAGMENT = "enableUserViewInFragment"
        const val KEY_ENABLE_USER_RESOURCE = "enableUserResource"
        const val KEY_ENABLE_APP_UI_BLOCK = "enableAppUIBlock"
        const val KEY_ENABLE_TRACK_NATIVE_APP_ANR = "enableTrackNativeAppANR"
        const val KEY_ENABLE_TRACK_NATIVE_CRASH = "enableTrackNativeCrash"
        const val KEY_NATIVE_UI_BLOCK_DURATION_MS = "nativeUiBlockDurationMS"
        const val KEY_ERROR_MONITOR_TYPE = "errorMonitorType"
        const val KEY_DEVICE_METRICS_MONITOR_TYPE = "deviceMetricsMonitorType"
        const val KEY_DETECT_FREQUENCY = "detectFrequency"
        const val KEY_RUM_CACHE_DISCARD = "rumCacheDiscard"
        const val KEY_RUM_CACHE_LIMIT_COUNT = "rumCacheLimitCount"

        const val KEY_LOG_TYPE = "logType"
        const val KEY_ENABLE_CUSTOM_LOG = "enableCustomLog"
        const val KEY_PRINT_CUSTOM_LOG_TO_CONSOLE = "printCustomLogToConsole"
        const val KEY_LOG_CACHE_DISCARD = "logCacheDiscard"
        const val KEY_LOG_CACHE_LIMIT_COUNT = "logCacheLimitCount"
    }

    private var tester: FTConfigCheck? = null

    @VisibleForTesting(otherwise = VisibleForTesting.PRIVATE)
    fun setChancelDebug(debug: Boolean) {
        tester = if (debug) FTConfigCheck() else null
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        if (BuildConfig.DEBUG) {
//            LogUtils.d(LOG_TAG, "${call.method} onMethodCall:${call.arguments}")
//        }
        when (call.method) {
            METHOD_CONFIG -> {
                val datakitUrl: String? = call.argument<String>(KEY_DATAKIT_URL)
                val datawayUrl: String? = call.argument<String>(KEY_DATAWAY_URL)
                val cliToken: String? = call.argument<String>(KEY_CLI_TOKEN)
                val debug: Boolean? = call.argument<Boolean>(KEY_DEBUG)
                val serviceName: String? = call.argument<String?>(KEY_SERVICE_NAME)
                val dataSyncRetryCount: Number? = call.argument<Number>(KEY_DATA_SYNC_RETRY_COUNT)
                val envType: String? = call.argument<String?>(KEY_ENV_TYPE);
                val globalContext: Map<String, String>? = call.argument(KEY_GLOBAL_CONTEXT)
                val enableAccessAndroidID: Boolean? =
                    call.argument<Boolean>(KEY_ENABLE_ACCESS_ANDROID_ID)
                val autoSync: Boolean? = call.argument<Boolean>(KEY_AUTO_SYNC)
                val syncPageSize: Number? = call.argument<Number>(KEY_SYNC_PAGE_SIZE)
                val customSyncPageSize: Number? = call.argument<Number>(KEY_CUSTOM_SYNC_PAGE_SIZE)
                val syncSleepTime: Number? = call.argument<Number>(KEY_SYNC_SLEEP_TIME)
                val compressIntakeRequests: Boolean? =
                    call.argument<Boolean>(KEY_COMPRESS_INTAKE_REQUESTS)
                val enableDataIntegerCompatible: Boolean? =
                    call.argument<Boolean>(KEY_ENABLE_DATA_INTEGER_COMPATIBLE)
                val enableLimitWithDbSize: Boolean? =
                    call.argument<Boolean>(KEY_ENABLE_LIMIT_WITH_DB_SIZE)
                val dbCacheLimit: Number? =
                    call.argument<Number>(KEY_DB_CACHE_LIMIT)
                val dbCacheDiscard: DBCacheDiscard =
                    DBCacheDiscard.values()[call.argument<Number>(KEY_DB_CACHE_DISCARD)?.toInt()
                        ?: DBCacheDiscard.DISCARD.ordinal]

                val dataModifier: Map<String, Any>? = call.argument(KEY_DATA_MODIFIER)
                val lineDataModifier: Map<String, Map<String, Any>>? =
                    call.argument(KEY_LINE_DATA_MODIFIER)
                val enableRemoteConfiguration: Boolean? = call.argument<Boolean>(
                    KEY_ENABLE_REMOTE_CONFIGURATION
                )
                val remoteConfigMiniUpdateInterval: Number? = call.argument<Number>(
                    KEY_REMOTE_CONFIG_MINI_UPDATE_INTERVAL
                )
                val pkgInfo: String? = call.argument<String?>(KEY_PKG_INFO)

                val sdkConfig =
                    if (datakitUrl != null) FTSDKConfig.builder(datakitUrl) else FTSDKConfig.builder(
                        datawayUrl,
                        cliToken
                    )

                sdkConfig.setEnv(envType).setDbCacheDiscard(dbCacheDiscard)

                if (debug != null) {
                    sdkConfig.isDebug = debug
                }
                globalContext?.forEach {
                    sdkConfig.addGlobalContext(it.key, it.value)
                }

                if (dataSyncRetryCount != null) {
                    sdkConfig.setDataSyncRetryCount(dataSyncRetryCount.toInt())
                }

                if (enableAccessAndroidID != null) {
                    sdkConfig.isEnableAccessAndroidID = enableAccessAndroidID
                }

                if (!serviceName.isNullOrEmpty()) {
                    sdkConfig.serviceName = serviceName
                }
                if (envType != null) {
                    sdkConfig.env = envType;
                }

                if (autoSync != null) {
                    sdkConfig.setAutoSync(autoSync)
                }

                if (syncPageSize != null) {
                    sdkConfig.setSyncPageSize(SyncPageSize.values()[syncPageSize.toInt()])
                }

                if (customSyncPageSize != null) {
                    sdkConfig.setCustomSyncPageSize(customSyncPageSize.toInt())
                }

                if (syncSleepTime != null) {
                    sdkConfig.setSyncSleepTime(syncSleepTime.toInt())
                }

                if (compressIntakeRequests != null) {
                    sdkConfig.setCompressIntakeRequests(compressIntakeRequests)
                }

                if (enableDataIntegerCompatible != null) {
                    if (enableDataIntegerCompatible) {
                        sdkConfig.enableDataIntegerCompatible()
                    }
                }

                if (enableLimitWithDbSize != null) {
                    if (dbCacheLimit != null) {
                        sdkConfig.enableLimitWithDbSize(dbCacheLimit.toLong())
                    } else {
                        sdkConfig.enableLimitWithDbSize()
                    }
                }
                if (dataModifier != null) {
                    sdkConfig.setDataModifier(object : DataModifier {
                        override fun modify(key: String, value: Any?): Any? {
                            return dataModifier[key]
                        }
                    })
                }

                if (lineDataModifier != null) {
                    sdkConfig.setLineDataModifier(object : LineDataModifier {
                        override fun modify(
                            measurement: String?,
                            data: HashMap<String, Any?>?
                        ): Map<String, Any?>? {
                            return if (measurement == Constants.FT_LOG_DEFAULT_MEASUREMENT) {
                                lineDataModifier["log"]
                            } else {
                                lineDataModifier[measurement]
                            }
                        }
                    })
                }

                if (enableRemoteConfiguration != null) {
                    sdkConfig.setRemoteConfiguration(enableRemoteConfiguration)
                }

                if (remoteConfigMiniUpdateInterval != null) {
                    sdkConfig.setRemoteConfigMiniUpdateInterval(remoteConfigMiniUpdateInterval.toInt())
                }

                if (pkgInfo != null) {
                    InnerClassProxy.addPkgInfo(sdkConfig, "flutter", pkgInfo)
                }
                FTSdk.install(sdkConfig)
//                LogUtils.d(LOG_TAG, Gson().toJson(sdkConfig))
                if (tester != null) {
                    result.success(
                        tester?.validateSDKConfig(
                            tester?.flutterArgsConvert(
                                call
                            ), sdkConfig
                        )
                    )
                } else {
                    result.success(null)
                }
            }

            METHOD_FLUSH_SYNC_DATA -> {
                FTSdk.flushSyncData()
                result.success(null)
            }

            METHOD_RUM_CONFIG -> {
                val rumAppId: String = call.argument<String>(KEY_RUM_APP_ID)!!
                val sampleRate: Double? = call.argument<Double>(KEY_SAMPLE_RATE)
                val sessionOnErrorSampleRate: Double? =
                    call.argument<Double>(KEY_SESSION_ON_ERROR_SAMPLE_RATE)
                val enableUserAction: Boolean? = call.argument<Boolean>(KEY_ENABLE_USER_ACTION)
                val enableUserView: Boolean? = call.argument<Boolean>(KEY_ENABLE_USER_VIEW)
                val enableUserViewInFragment: Boolean? = call.argument<Boolean>(
                    KEY_ENABLE_USER_VIEW_IN_FRAGMENT
                )
                val enableUserResource: Boolean? = call.argument<Boolean>(KEY_ENABLE_USER_RESOURCE)
                val enableAppUIBlock: Boolean? = call.argument<Boolean>(KEY_ENABLE_APP_UI_BLOCK)
                val enableTrackNativeAppANR: Boolean? =
                    call.argument<Boolean>(KEY_ENABLE_TRACK_NATIVE_APP_ANR)
                val enableTrackNativeCrash: Boolean? =
                    call.argument<Boolean>(KEY_ENABLE_TRACK_NATIVE_CRASH)
                val uiBlockDurationMS: Number? = call.argument<Number>(
                    KEY_NATIVE_UI_BLOCK_DURATION_MS
                )
                val errorMonitorType: Number? = call.argument<Number>(KEY_ERROR_MONITOR_TYPE)
                val deviceMetricsMonitorType: Number? =
                    call.argument<Number>(KEY_DEVICE_METRICS_MONITOR_TYPE)
                val detectFrequency: Number? = call.argument<Number>(KEY_DETECT_FREQUENCY)
                val globalContext: Map<String, String>? = call.argument(KEY_GLOBAL_CONTEXT)
                val rumCacheDiscard: RUMCacheDiscard =
                    RUMCacheDiscard.values()[call.argument<Number>(KEY_RUM_CACHE_DISCARD)?.toInt()
                        ?: RUMCacheDiscard.DISCARD.ordinal]
                val rumCacheLimitCount: Number? = call.argument<Number>(KEY_RUM_CACHE_LIMIT_COUNT)

                val enableTraceWebView: Boolean? = call.argument<Boolean>(KEY_ENABLE_TRACE_WEBVIEW)
                val allowWebViewHost: List<String>? = call.argument<List<String>>(
                    KEY_ALLOW_WEBVIEW_HOST
                )


                val rumConfig = FTRUMConfig().setRumAppId(rumAppId)
                    .setRumCacheDiscardStrategy(rumCacheDiscard)
                if (sampleRate != null) {
                    rumConfig.samplingRate = sampleRate.toFloat()
                }

                if (sessionOnErrorSampleRate != null) {
                    rumConfig.sessionErrorSampleRate = sessionOnErrorSampleRate.toFloat()
                }

                if (enableUserAction != null) {
                    rumConfig.isEnableTraceUserAction = enableUserAction
                }

                if (enableUserView != null) {
                    rumConfig.isEnableTraceUserView = enableUserView
                }

                if (enableUserViewInFragment != null) {
                    rumConfig.isEnableTraceUserViewInFragment = enableUserViewInFragment
                }

                if (enableUserResource != null) {
                    rumConfig.isEnableTraceUserResource = enableUserResource
                }

                if (enableAppUIBlock != null) {
                    if (uiBlockDurationMS != null) {
                        rumConfig.setEnableTrackAppUIBlock(
                            enableAppUIBlock,
                            uiBlockDurationMS.toLong()
                        )
                    } else {
                        rumConfig.isEnableTrackAppUIBlock = enableAppUIBlock
                    }
                }
                if (enableTrackNativeCrash != null) {
                    rumConfig.isEnableTrackAppCrash = enableTrackNativeCrash
                }
                if (enableTrackNativeAppANR != null) {
                    rumConfig.isEnableTrackAppANR = enableTrackNativeAppANR
                }
                if (errorMonitorType != null) {
                    rumConfig.extraMonitorTypeWithError = errorMonitorType.toInt()

                }

                if (deviceMetricsMonitorType != null) {


                    if (detectFrequency != null) {
                        val detectFrequencyEnum: DetectFrequency =
                            DetectFrequency.values()[detectFrequency.toInt()]
                        rumConfig.setDeviceMetricsMonitorType(
                            deviceMetricsMonitorType.toInt(),
                            detectFrequencyEnum
                        )
                    } else {
                        rumConfig.deviceMetricsMonitorType = deviceMetricsMonitorType.toInt()
                    }
                }

                globalContext?.forEach {
                    rumConfig.addGlobalContext(it.key, it.value)
                }

                if (rumCacheLimitCount != null) {
                    rumConfig.rumCacheLimitCount = rumCacheLimitCount.toInt()
                }

                if (enableTraceWebView != null) {
                    rumConfig.setEnableTraceWebView(enableTraceWebView)
                }

                if (allowWebViewHost != null) {
                    val arr: Array<String?> = allowWebViewHost.toTypedArray()
                    rumConfig.setAllowWebViewHost(arr)
                }

                FTSdk.initRUMWithConfig(rumConfig)

                if (tester != null) {
                    result.success(
                        tester?.validateRUMConfig(
                            tester?.flutterArgsConvert(
                                call
                            ), rumConfig
                        )
                    )
                } else {
                    result.success(null)
                }
//                LogUtils.d(LOG_TAG, Gson().toJson(rumConfig))

            }

            METHOD_RUM_ADD_ACTION -> {
                val actionName: String? = call.argument<String>("actionName")
                val actionType: String? = call.argument<String>("actionType")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().addAction(actionName, actionType, property)
                result.success(null)
            }

            METHOD_RUM_START_ACTION -> {
                val actionName: String? = call.argument<String>("actionName")
                val actionType: String? = call.argument<String>("actionType")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().startAction(actionName, actionType, property)
                result.success(null)
            }

            METHOD_RUM_CREATE_VIEW -> {
                val viewName: String? = call.argument<String>("viewName")
                val duration: Number? = call.argument<Number>("duration")
                FTRUMGlobalManager.get().onCreateView(viewName, duration?.toLong() ?: -1L)
                result.success(null)
            }

            METHOD_RUM_START_VIEW -> {
                val viewName: String? = call.argument<String>("viewName")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().startView(viewName, property)
                result.success(null)
            }

            METHOD_RUM_STOP_VIEW -> {
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().stopView(property)
                result.success(null)
            }

            METHOD_RUM_ADD_ERROR -> {
                val stack: String? = call.argument<String>("stack")
                val message: String? = call.argument<String>("message")
                val state: Int? = call.argument<Int>("appState")
                var errorType: String? = call.argument<String>("errorType")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }

                val appState: AppState = AppState.values()[state ?: AppState.UNKNOWN.ordinal]
                if (errorType.isNullOrEmpty()) {
                    errorType = ErrorType.FLUTTER.toString()
                }
                FTRUMGlobalManager.get().addError(stack, message, errorType, appState, property)
                result.success(null)

            }

            METHOD_RUM_START_RESOURCE -> {
                val key: String? = call.argument<String>("key")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().startResource(key, property)
                result.success(null)
            }

            METHOD_RUM_STOP_RESOURCE -> {
                val key: String? = call.argument<String>("key")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }
                FTRUMGlobalManager.get().stopResource(key, property)
                result.success(null)

            }

            METHOD_RUM_ADD_RESOURCE -> {
                val key: String? = call.argument<String>("key")
                val method: String? = call.argument<String>("resourceMethod")
                val requestHeader: Map<String, Any>? =
                    call.argument<Map<String, Any>>("requestHeader")
                val responseHeader: Map<String, Any>? =
                    call.argument<Map<String, Any>>("responseHeader")
                val responseBody: String? = call.argument<String>("responseBody")
//                val responseConnection: String? = call.argument<String>("responseConnection")
//                val responseContentType: String? = call.argument<String>("responseContentType")
//                val responseContentEncoding: String? =
//                    call.argument<String>("responseContentEncoding")
                val resourceStatus: Int? = call.argument<Int>("resourceStatus")
                val resourceSize: Number? = call.argument<Number>("resourceSize")
                val url: String? = call.argument<String>("url")
//                val fetchStartTime: Long? = call.argument<Long>("fetchStartTime")
//                val tcpStartTime: Long? = call.argument<Long>("tcpStartTime")
//                val tcpEndTime: Long? = call.argument<Long>("tcpEndTime")
//                val dnsStartTime: Long? = call.argument<Long>("dnsStartTime")
//                val dnsEndTime: Long? = call.argument<Long>("dnsEndTime")
//                val responseStartTime: Long? = call.argument<Long>("responseStartTime")
//                val responseEndTime: Long? = call.argument<Long>("responseEndTime")
//                val sslStartTime: Long? = call.argument<Long>("sslStartTime")
//                val sslEndTime: Long? = call.argument<Long>("sslEndTime")


                val params = ResourceParams()
                val netStatusBean = NetStatusBean()
                params.resourceMethod = method

                if (requestHeader != null) {
                    params.requestHeaderMap = getHashMap(requestHeader)
                }

                if (responseHeader != null) {
                    params.responseHeaderMap = getHashMap(responseHeader)
                }

                if (resourceSize != null) {
                    params.responseContentLength = resourceSize.toLong()
                }

                val responseContentType =
                    responseHeader?.get("content-type")?.toString()?.replace(Regex("[\\[\\]]"), "")
                val responseConnection: String? =
                    responseHeader?.get("connection")?.toString()?.replace(Regex("[\\[\\]]"), "")
                val responseContentEncoding: String? =
                    responseContentType?.split(";")?.last()

                params.resourceStatus = resourceStatus ?: 0
                params.responseBody = responseBody ?: ""
                params.responseConnection = responseConnection ?: ""
                params.responseContentType = responseContentType ?: ""
                params.responseContentEncoding = responseContentEncoding ?: ""
                params.url = url ?: ""
//                netStatusBean.fetchStartTime = fetchStartTime!!
//                netStatusBean.tcpStartTime = tcpStartTime!!
//                netStatusBean.tcpEndTime = tcpEndTime!!
//                netStatusBean.dnsStartTime = dnsStartTime!!
//                netStatusBean.dnsEndTime = dnsEndTime!!
//                netStatusBean.responseStartTime = responseStartTime!!
//                netStatusBean.responseEndTime = responseEndTime!!
//                netStatusBean.sslStartTime = sslStartTime!!
//                netStatusBean.sslEndTime = sslEndTime!!
                FTRUMGlobalManager.get().addResource(key, params, netStatusBean)
                result.success(null)
            }

            METHOD_LOG_CONFIG -> {
                val sampleRate: Double? = call.argument<Double>(KEY_SAMPLE_RATE)
                val logTypeArr: List<Int>? = call.argument<List<Int>>(KEY_LOG_TYPE)
                val enableLinkRumData: Boolean? = call.argument<Boolean>(KEY_ENABLE_LINK_RUM_DATA)
                val enableCustomLog: Boolean? = call.argument<Boolean>(KEY_ENABLE_CUSTOM_LOG)
                val printCustomLogToConsole: Boolean? =
                    call.argument<Boolean>(KEY_PRINT_CUSTOM_LOG_TO_CONSOLE)
                val globalContext: Map<String, String>? = call.argument(KEY_GLOBAL_CONTEXT)

                val logCacheDiscard: LogCacheDiscard =
                    LogCacheDiscard.values()[call.argument<Int>(KEY_LOG_CACHE_DISCARD)
                        ?: LogCacheDiscard.DISCARD.ordinal]
                val logCacheLimitCount: Int? = call.argument<Int>(KEY_LOG_CACHE_LIMIT_COUNT)

                val logConfig = FTLoggerConfig()
                    .setLogCacheDiscardStrategy(logCacheDiscard)

                if (sampleRate != null) {
                    logConfig.samplingRate = sampleRate.toFloat()
                }

                if (logTypeArr != null) {
                    val arr: Array<Status?> = arrayOfNulls(logTypeArr.size)

                    logTypeArr.forEachIndexed { index, it ->
                        arr[index] = Status.values()
                            .find { status ->
                                if (it > Status.INFO.ordinal)
                                    it + 1 == status.ordinal else it == status.ordinal
                            }!!
                    }
                    logConfig.setLogLevelFilters(arr)
                }

                if (enableLinkRumData != null) {
                    logConfig.isEnableLinkRumData = enableLinkRumData
                }
                if (enableCustomLog != null) {
                    logConfig.isEnableCustomLog = enableCustomLog
                }

                if (printCustomLogToConsole != null) {
                    logConfig.isPrintCustomLogToConsole = printCustomLogToConsole;
                }

                if (logCacheLimitCount != null) {
                    logConfig.logCacheLimitCount = logCacheLimitCount;
                }

                globalContext?.forEach {
                    logConfig.addGlobalContext(it.key, it.value)
                }

                FTSdk.initLogWithConfig(logConfig)

                if (tester != null) {
                    result.success(
                        tester?.validateLogConfig(
                            tester?.flutterArgsConvert(
                                call
                            ), logConfig
                        )
                    )
                } else {
                    result.success(null)
                }
//                LogUtils.d(LOG_TAG, Gson().toJson(logConfig))
            }


            METHOD_LOGGING -> {
                val content: String = call.argument<String>("content") ?: ""
                val status: Status =
                    Status.values()[call.argument<Int>("status") ?: Status.INFO.ordinal]
                val isSilence: Boolean? = call.argument<Boolean>("isSilence")
                val mapProperty: Map<String, Any>? = call.argument("property")
                val property: HashMap<String, Any>? = mapProperty?.let { HashMap(mapProperty) }

                if (isSilence != null) {
                    FTLogger.getInstance().logBackground(content, status, property, isSilence)
                } else {
                    FTLogger.getInstance().logBackground(content, status, property)
                }
                result.success(null)
            }

            METHOD_TRACE_CONFIG -> {
                val sampleRate: Double? = call.argument<Double>(KEY_SAMPLE_RATE)
                val traceType = call.argument<Int>(KEY_TRACE_TYPE)
                val enableLinkRUMData = call.argument<Boolean>(KEY_ENABLE_LINK_RUM_DATA)
                val enableAutoTrace = call.argument<Boolean>(KEY_ENABLE_NATIVE_AUTO_TRACE)

                val traceConfig = FTTraceConfig()
                if (sampleRate != null) {
                    traceConfig.samplingRate = sampleRate.toFloat()
                }

                if (traceType != null) {
                    traceConfig.traceType = TraceType.values()[traceType]
                }

                if (enableLinkRUMData != null) {
                    traceConfig.isEnableLinkRUMData = enableLinkRUMData
                }

                if (enableAutoTrace != null) {
                    traceConfig.isEnableAutoTrace = enableAutoTrace
                }
                if (enableAutoTrace != null) {
                    traceConfig.isEnableAutoTrace = enableAutoTrace
                }

                FTSdk.initTraceWithConfig(traceConfig)
                if (tester != null) {
                    result.success(
                        tester?.validateTraceConfig(
                            tester?.flutterArgsConvert(
                                call
                            ), traceConfig
                        )
                    )
                } else {
                    result.success(null)

                }
//                LogUtils.d(LOG_TAG, Gson().toJson(traceConfig))

            }
//            METHOD_TRACE -> {
//                val key: String? = call.argument<String>("key")
//                val httpMethod: String? = call.argument("httpMethod")
//                val requestHeader: HashMap<String, String>? = call.argument("requestHeader")
//                val responseHeader: HashMap<String, String>? = call.argument("responseHeader")
//                val statusCode: Int? = call.argument("statusCode")
//                val errorMsg: String? = call.argument("errorMessage")
//
//                FTTraceManager.get().addTrace(
//                        key, httpMethod, requestHeader,
//                        responseHeader, statusCode ?: 0, errorMsg ?: ""
//                )
//                result.success(null)
//
//            }
            METHOD_GET_TRACE_HEADER -> {
                val url: String? = call.argument<String>("url")
                val key: String? = call.argument<String>("key")

                if (key != null) {
                    result.success(FTTraceManager.get().getTraceHeader(key, url))
                } else {
                    result.success(FTTraceManager.get().getTraceHeader(url))
                }
            }

            METHOD_BIND_USER -> {
                val userId: String? = call.argument<String>("userId")
                val userName: String? = call.argument<String>("userName")
                val userEmail: String? = call.argument<String>("userEmail")
                val userExt: Map<String, String>? = call.argument("userExt")

                val userData = UserData()
                if (userId != null) {
                    userData.id = userId
                }
                if (userId != null) {
                    userData.name = userName
                }
                if (userId != null) {
                    userData.email = userEmail
                }
                if (userExt != null) {
                    val map = hashMapOf<String, String>()
                    userExt.forEach {
                        map[it.key] = it.value
                    }
                    userData.exts = map
                }

                FTSdk.bindRumUserData(userData)
                result.success(null)
            }

            METHOD_UNBIND_USER -> {
                FTSdk.unbindRumUserData()
                result.success(null)
            }

            METHOD_ENABLE_ACCESS_ANDROID_ID -> {
                val enableAccessAndroidID: Boolean? =
                    call.argument<Boolean>("enableAccessAndroidID")
                FTSdk.setEnableAccessAndroidID(enableAccessAndroidID!!)
                result.success(null)
            }

            METHOD_SET_INNER_LOG_HANDLER -> {
                LogUtils.registerInnerLogHandler { level, tag, message ->
                    handler?.post {
                        channel.invokeMethod(
                            METHOD_INVOKE_INNER_LOG, mapOf(
                                "level" to level,
                                "tag" to tag,
                                "message" to message
                            )
                        )
                    }
                }
                result.success(null)
            }

            METHOD_APPEND_GLOBAL_CONTEXT -> {
                val globalContext: Map<String, Any>? = call.argument("globalContext")
                FTSdk.appendGlobalContext(globalContext?.let { HashMap(it) })
                result.success(null)
            }

            METHOD_APPEND_LOG_GLOBAL_CONTEXT -> {
                val globalContext: Map<String, Any>? = call.argument("globalContext")
                FTSdk.appendLogGlobalContext(globalContext?.let { HashMap(it) })
                result.success(null)
            }

            METHOD_APPEND_RUM_GLOBAL_CONTEXT -> {
                val globalContext: Map<String, Any>? = call.argument("globalContext")
                FTSdk.appendRUMGlobalContext(globalContext?.let { HashMap(it) })
                result.success(null)

            }

            METHOD_CLEAR_ALL_DATA -> {
                FTSdk.clearAllData()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getHashMap(header: Map<String, Any>): HashMap<String, List<String>> {
        val hashMap = hashMapOf<String, List<String>>()
        header.forEach { it ->
            if (it.value is String) {
                hashMap[it.key] = listOf(it.value.toString())
            } else if (it.value is List<*>) {
                hashMap[it.key] = it.value as List<String>
            }
        }
        return hashMap
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}