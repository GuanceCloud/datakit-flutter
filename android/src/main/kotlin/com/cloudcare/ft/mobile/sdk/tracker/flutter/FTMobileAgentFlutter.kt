package com.cloudcare.ft.mobile.sdk.tracker.flutter

import android.app.Application
import android.os.Handler
import android.os.Looper
import android.view.ViewGroup
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
//import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** AgentPlugin */
class FTMobileAgentFlutter : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var application: Application
    private var viewGroup: ViewGroup? = null

    private val handler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ft_mobile_agent_flutter")
        channel.setMethodCallHandler(this)
        application = flutterPluginBinding.applicationContext as Application
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
        const val LOG_TAG = "FTMobileAgentFlutter"
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


    }

    override fun onMethodCall(call: MethodCall, result: Result) {
//        if (BuildConfig.DEBUG) {
//            LogUtils.d(LOG_TAG, "${call.method} onMethodCall:${call.arguments}")
//        }
        when (call.method) {
            METHOD_CONFIG -> {
                val datakitUrl: String? = call.argument<String>("datakitUrl")
                val datawayUrl: String? = call.argument<String>("datawayUrl")
                val cliToken: String? = call.argument<String>("cliToken")
                val debug: Boolean? = call.argument<Boolean>("debug")
                val serviceName: String? = call.argument<String?>("serviceName")
                val dataSyncRetryCount: Number? = call.argument<Number>("dataSyncRetryCount")
                val envType: String? = call.argument<String?>("env");
                val globalContext: Map<String, String>? = call.argument("globalContext")
                val enableAccessAndroidID: Boolean? =
                    call.argument<Boolean>("enableAccessAndroidID")
                val autoSync: Boolean? = call.argument<Boolean>("autoSync")
                val syncPageSize: Number? = call.argument<Number>("syncPageSize")
                val customSyncPageSize: Number? = call.argument<Number>("customSyncPageSize")
                val syncSleepTime: Number? = call.argument<Number>("syncSleepTime")
                val compressIntakeRequests: Boolean? =
                    call.argument<Boolean>("compressIntakeRequests")
                val enableDataIntegerCompatible: Boolean? =
                    call.argument<Boolean>("enableDataIntegerCompatible")
                val enableLimitWithDbSize: Boolean? =
                    call.argument<Boolean>("enableLimitWithDbSize")
                val dbCacheLimit: Number? =
                    call.argument<Number>("dbCacheLimit")
                val dbCacheDiscard: DBCacheDiscard =
                    DBCacheDiscard.values()[call.argument<Number>("dbCacheDiscard")?.toInt()
                        ?: DBCacheDiscard.DISCARD.ordinal]

                val dataModifier: Map<String, Any>? = call.argument("dataModifier")
                val lineDataModifier: Map<String, Map<String, Any>>? = call.argument("lineDataModifier")
                val pkgInfo: String? = call.argument<String?>("pkgInfo")

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
                    sdkConfig.setLineDataModifier(object :LineDataModifier{
                        override fun modify(
                            measurement: String?,
                            data: HashMap<String, Any?>?
                        ): Map<String, Any?>? {
                            return if(measurement == Constants.FT_LOG_DEFAULT_MEASUREMENT){
                                lineDataModifier["log"]
                            }else{
                                lineDataModifier[measurement]
                            }
                        }
                    })
                }

                if (pkgInfo != null) {
                    InnerClassProxy.addPkgInfo(sdkConfig, "flutter", pkgInfo)
                }
                FTSdk.install(sdkConfig)
                result.success(null)
//                LogUtils.d(LOG_TAG, Gson().toJson(sdkConfig))
            }

            METHOD_FLUSH_SYNC_DATA -> {
                FTSdk.flushSyncData()
                result.success(null)
            }

            METHOD_RUM_CONFIG -> {
                val rumAppId: String = call.argument<String>("rumAppId")!!
                val sampleRate: Double? = call.argument<Double>("sampleRate")
                val sessionOnErrorSampleRate: Double? = call.argument<Double>("sessionOnErrorSampleRate")
                val enableUserAction: Boolean? = call.argument<Boolean>("enableUserAction")
                val enableUserView: Boolean? = call.argument<Boolean>("enableUserView")
                val enableUserResource: Boolean? = call.argument<Boolean>("enableUserResource")
                val enableAppUIBlock: Boolean? = call.argument<Boolean>("enableAppUIBlock")
                val enableTrackNativeAppANR: Boolean? =
                    call.argument<Boolean>("enableTrackNativeAppANR")
                val enableTrackNativeCrash: Boolean? =
                    call.argument<Boolean>("enableTrackNativeCrash")
                val uiBlockDurationMS: Number? = call.argument<Number>("nativeUiBlockDurationMS")
                val errorMonitorType: Number? = call.argument<Number>("errorMonitorType")
                val deviceMetricsMonitorType: Number? =
                    call.argument<Number>("deviceMetricsMonitorType")
                val detectFrequency: Number? = call.argument<Number>("detectFrequency")
                val globalContext: Map<String, String>? = call.argument("globalContext")
                val rumCacheDiscard: RUMCacheDiscard =
                    RUMCacheDiscard.values()[call.argument<Number>("rumCacheDiscard")?.toInt()
                        ?: RUMCacheDiscard.DISCARD.ordinal]
                val rumCacheLimitCount: Number? = call.argument<Number>("rumCacheLimitCount")

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

                FTSdk.initRUMWithConfig(rumConfig)
                result.success(null)
//                LogUtils.d(LOG_TAG, Gson().toJson(rumConfig))

            }

            METHOD_RUM_ADD_ACTION -> {
                val actionName: String? = call.argument<String>("actionName")
                val actionType: String? = call.argument<String>("actionType")
                FTRUMGlobalManager.get().startAction(actionName, actionType)
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
                val sampleRate: Double? = call.argument<Double>("sampleRate")
                val logTypeArr: List<Int>? = call.argument<List<Int>>("logType")
                val enableLinkRumData: Boolean? = call.argument<Boolean>("enableLinkRumData")
                val enableCustomLog: Boolean? = call.argument<Boolean>("enableCustomLog")
                val printCustomLogToConsole: Boolean? =
                    call.argument<Boolean>("printCustomLogToConsole")
                val globalContext: Map<String, String>? = call.argument("globalContext")

                val logCacheDiscard: LogCacheDiscard =
                    LogCacheDiscard.values()[call.argument<Int>("logCacheDiscard")
                        ?: LogCacheDiscard.DISCARD.ordinal]
                val logCacheLimitCount: Int? = call.argument<Int>("logCacheLimitCount")

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
                result.success(null)
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
                val sampleRate: Double? = call.argument<Double>("sampleRate")
                val traceType = call.argument<Int>("traceType")
                val enableLinkRUMData = call.argument<Boolean>("enableLinkRUMData")
                val enableAutoTrace = call.argument<Boolean>("enableNativeAutoTrace")

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
                result.success(null)
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
                    handler.post {
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
