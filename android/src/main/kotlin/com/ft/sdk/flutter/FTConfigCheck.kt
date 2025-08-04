package com.ft.sdk.flutter

import com.ft.sdk.FTLoggerConfig
import com.ft.sdk.FTRUMConfig
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTTraceConfig
import com.ft.sdk.SyncPageSize
import com.ft.sdk.garble.bean.Status
import com.ft.sdk.garble.utils.Constants
import com.ft.sdk.garble.utils.LogUtils
import io.flutter.plugin.common.MethodCall
import java.util.Arrays
import java.util.Objects

class FTConfigCheck {
    companion object {
        private const val LOG_TAG = "${Constants.LOG_TAG_PREFIX}FTConfigCheck"
        private const val EPSILON = 1e-6
    }

    /**
     * Validate SDK configuration
     * @param args Parameters passed from Flutter
     * @param sdkConfig SDK configuration object
     */
    fun validateSDKConfig(args: Map<String, Any?>?, sdkConfig: FTSDKConfig): Boolean {
        val configMap = mapOf(
            FTMobileAgentFlutter.KEY_DATAKIT_URL to sdkConfig.datakitUrl,
            FTMobileAgentFlutter.KEY_DATAWAY_URL to sdkConfig.datawayUrl,
            FTMobileAgentFlutter.KEY_CLI_TOKEN to sdkConfig.clientToken,
            FTMobileAgentFlutter.KEY_ENV_TYPE to sdkConfig.env,
            FTMobileAgentFlutter.KEY_DEBUG to sdkConfig.isDebug,
            FTMobileAgentFlutter.KEY_SERVICE_NAME to sdkConfig.serviceName,
            FTMobileAgentFlutter.KEY_AUTO_SYNC to sdkConfig.isAutoSync,
            FTMobileAgentFlutter.KEY_SYNC_PAGE_SIZE to sdkConfig.pageSize,
            FTMobileAgentFlutter.KEY_CUSTOM_SYNC_PAGE_SIZE to sdkConfig.pageSize,
            FTMobileAgentFlutter.KEY_SYNC_SLEEP_TIME to sdkConfig.syncSleepTime,
            FTMobileAgentFlutter.KEY_COMPRESS_INTAKE_REQUESTS to sdkConfig.isCompressIntakeRequests,
            FTMobileAgentFlutter.KEY_ENABLE_DATA_INTEGER_COMPATIBLE to sdkConfig.isEnableDataIntegerCompatible,
            FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT to sdkConfig.globalContext,
            FTMobileAgentFlutter.KEY_ENABLE_LIMIT_WITH_DB_SIZE to sdkConfig.isLimitWithDbSize,
            FTMobileAgentFlutter.KEY_DB_CACHE_LIMIT to sdkConfig.dbCacheLimit,
            FTMobileAgentFlutter.KEY_DB_CACHE_DISCARD to sdkConfig.dbCacheDiscard.ordinal,
            FTMobileAgentFlutter.KEY_LINE_DATA_MODIFIER to sdkConfig.lineDataModifier,
            FTMobileAgentFlutter.KEY_DATA_MODIFIER to sdkConfig.dataModifier,
            FTMobileAgentFlutter.KEY_ENABLE_REMOTE_CONFIGURATION to sdkConfig.isRemoteConfiguration,
            FTMobileAgentFlutter.KEY_REMOTE_CONFIG_MINI_UPDATE_INTERVAL to sdkConfig.remoteConfigMiniUpdateInterval
        )

        if (args != null) {
            for ((key, value) in args) {
                if (value == null) continue

                when (key) {
                    FTMobileAgentFlutter.KEY_SYNC_PAGE_SIZE -> {
                        val syncPageSizeOrdinal = value as Int
                        val syncPageSize = SyncPageSize.values()[syncPageSizeOrdinal].value
                        val match = syncPageSize == sdkConfig.pageSize
                        if (!match) {
                            logNotMatch(key, value, syncPageSize)
                            return false
                        }
                    }
                    FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT -> {
                        val match = globalContextCheck(value as? Map<*, *>, key, sdkConfig.globalContext)
                        if (!match) return false
                    }
                    FTMobileAgentFlutter.KEY_DATA_MODIFIER -> {
                        val match = value != null && sdkConfig.dataModifier != null
                        if (!match) {
                            logNotMatch(key, value, sdkConfig.dataModifier)
                            return false
                        }
                    }
                    FTMobileAgentFlutter.KEY_LINE_DATA_MODIFIER -> {
                        val match = value != null && sdkConfig.lineDataModifier != null
                        if (!match) {
                            logNotMatch(key, value, sdkConfig.lineDataModifier)
                            return false
                        }
                    }
                    else -> {
                        val match = normalItemCheck(key, value, configMap)
                        if (!match) return false
                    }
                }
            }
        }
        return true
    }

    /**
     * Validate RUM configuration
     * @param args Parameters passed from Flutter
     * @param sdkConfig RUM configuration object
     */
    fun validateRUMConfig(args: Map<String, Any?>?, sdkConfig: FTRUMConfig): Boolean {
        val configMap = mapOf(
            FTMobileAgentFlutter.KEY_RUM_APP_ID to sdkConfig.rumAppId,
            FTMobileAgentFlutter.KEY_SAMPLE_RATE to sdkConfig.samplingRate,
            FTMobileAgentFlutter.KEY_SESSION_ON_ERROR_SAMPLE_RATE to sdkConfig.sessionErrorSampleRate,
            FTMobileAgentFlutter.KEY_ENABLE_USER_ACTION to sdkConfig.isEnableTraceUserAction,
            FTMobileAgentFlutter.KEY_ENABLE_USER_VIEW to sdkConfig.isEnableTraceUserView,
            FTMobileAgentFlutter.KEY_ENABLE_USER_VIEW_IN_FRAGMENT to sdkConfig.isEnableTraceUserViewInFragment,
            FTMobileAgentFlutter.KEY_ENABLE_USER_RESOURCE to sdkConfig.isEnableTraceUserResource,
            FTMobileAgentFlutter.KEY_ENABLE_APP_UI_BLOCK to sdkConfig.isEnableTrackAppUIBlock,
            FTMobileAgentFlutter.KEY_NATIVE_UI_BLOCK_DURATION_MS to sdkConfig.blockDurationMS,
            FTMobileAgentFlutter.KEY_ENABLE_TRACK_NATIVE_APP_ANR to sdkConfig.isEnableTrackAppANR,
            FTMobileAgentFlutter.KEY_ENABLE_TRACK_NATIVE_CRASH to sdkConfig.isEnableTrackAppCrash,
            FTMobileAgentFlutter.KEY_ERROR_MONITOR_TYPE to sdkConfig.extraMonitorTypeWithError,
            FTMobileAgentFlutter.KEY_DEVICE_METRICS_MONITOR_TYPE to sdkConfig.deviceMetricsMonitorType,
            FTMobileAgentFlutter.KEY_DETECT_FREQUENCY to sdkConfig.deviceMetricsDetectFrequency.ordinal,
            FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT to sdkConfig.globalContext,
            FTMobileAgentFlutter.KEY_RUM_CACHE_LIMIT_COUNT to sdkConfig.rumCacheLimitCount,
            FTMobileAgentFlutter.KEY_RUM_CACHE_DISCARD to sdkConfig.rumCacheDiscardStrategy.ordinal,
            FTMobileAgentFlutter.KEY_ENABLE_TRACE_WEBVIEW to sdkConfig.isEnableTraceWebView,
            FTMobileAgentFlutter.KEY_ALLOW_WEBVIEW_HOST to sdkConfig.allowWebViewHost
        )

        if (args != null) {
            for ((key, value) in args) {
                if (value == null) continue

                when (key) {
                    FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT -> {
                        val match = globalContextCheck(value as? Map<*, *>, key, sdkConfig.globalContext)
                        if (!match) return false
                    }
                    FTMobileAgentFlutter.KEY_DEVICE_METRICS_MONITOR_TYPE -> {
                        val match = (value as Number).toInt() == sdkConfig.deviceMetricsMonitorType
                        if (!match) {
                            logNotMatch(key, value, sdkConfig.deviceMetricsMonitorType)
                            return false
                        }
                    }
                    FTMobileAgentFlutter.KEY_ERROR_MONITOR_TYPE -> {
                        val match = (value as Number).toInt() == sdkConfig.extraMonitorTypeWithError
                        if (!match) {
                            logNotMatch(key, value, sdkConfig.extraMonitorTypeWithError)
                            return false
                        }
                    }
                    FTMobileAgentFlutter.KEY_ALLOW_WEBVIEW_HOST -> {
                        if (value is List<*>) {
                            val list = value as List<String>
                            val match =
                                Arrays.equals(list.toTypedArray(), sdkConfig.allowWebViewHost)
                            if (!match) {
                                logNotMatch(key, value, sdkConfig.allowWebViewHost)
                                return false
                            }
                        }
                    }
                    else -> {
                        val check = normalItemCheck(key, value, configMap)
                        if (!check) return false
                    }
                }
            }
        }
        return true
    }

    /**
     * Validate log configuration
     * @param args Parameters passed from Flutter
     * @param sdkConfig Log configuration object
     */
    fun validateLogConfig(args: Map<String, Any?>?, sdkConfig: FTLoggerConfig): Boolean {
        val configMap = mapOf(
            FTMobileAgentFlutter.KEY_SAMPLE_RATE to sdkConfig.samplingRate,
            FTMobileAgentFlutter.KEY_ENABLE_LINK_RUM_DATA to sdkConfig.isEnableLinkRumData,
            FTMobileAgentFlutter.KEY_ENABLE_CUSTOM_LOG to sdkConfig.isEnableCustomLog,
            FTMobileAgentFlutter.KEY_LOG_CACHE_DISCARD to sdkConfig.logCacheDiscardStrategy.ordinal,
            FTMobileAgentFlutter.KEY_LOG_CACHE_LIMIT_COUNT to sdkConfig.logCacheLimitCount,
            FTMobileAgentFlutter.KEY_PRINT_CUSTOM_LOG_TO_CONSOLE to sdkConfig.isPrintCustomLogToConsole,
            FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT to sdkConfig.globalContext
        )

        if (args != null) {
            for ((key, value) in args) {
                if (value == null) continue

                when (key) {
                    FTMobileAgentFlutter.KEY_LOG_TYPE -> {
                        if (value is List<*>) {
                            for (item in value) {
                                if (item is Int) {
                                    val level = item
                                    val status = Status.values().find { status ->
                                        if (level > Status.INFO.ordinal) {
                                            level + 1 == status.ordinal
                                        } else {
                                            level == status.ordinal
                                        }
                                    }
                                    if (status != null && !sdkConfig.checkLogLevel(status.name)) {
                                        logNotMatch(key, value, status.name)
                                        return false
                                    }
                                }
                            }
                        }
                    }
                    FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT -> {
                        val match = globalContextCheck(value as? Map<*, *>, key, sdkConfig.globalContext)
                        if (!match) return false
                    }
                    else -> {
                        val match = normalItemCheck(key, value, configMap)
                        if (!match) return false
                    }
                }
            }
        }
        return true
    }

    /**
     * Validate trace configuration
     * @param args Parameters passed from Flutter
     * @param sdkConfig Trace configuration object
     */
    fun validateTraceConfig(args: Map<String, Any?>?, sdkConfig: FTTraceConfig): Boolean {
        val configMap = mapOf(
            FTMobileAgentFlutter.KEY_SAMPLE_RATE to sdkConfig.samplingRate,
            FTMobileAgentFlutter.KEY_TRACE_TYPE to sdkConfig.traceType.ordinal,
            FTMobileAgentFlutter.KEY_ENABLE_LINK_RUM_DATA to sdkConfig.isEnableLinkRUMData,
            FTMobileAgentFlutter.KEY_ENABLE_NATIVE_AUTO_TRACE to sdkConfig.isEnableAutoTrace
        )

        if (args != null) {
            for ((key, value) in args) {
                if (value == null) continue

                val match = normalItemCheck(key, value, configMap)
                if (!match) return false
            }
        }
        return true
    }

    /**
     * Check global context configuration
     * @param flutterMap Flutter global context map
     * @param keyStr Key string for logging
     * @param realGlobalContext Real global context from SDK
     */
    private fun globalContextCheck(
        flutterMap: Map<*, *>?,
        keyStr: String,
        realGlobalContext: Map<*, *>?
    ): Boolean {
        if (flutterMap != null) {
            for ((key, value) in flutterMap) {
                val match = Objects.equals(realGlobalContext?.get(key), value)
                if (!match) {
                    LogUtils.e(LOG_TAG, "key:$keyStr, value:$value, config:$realGlobalContext, not match")
                    return false
                }
            }
        }
        return true
    }

    /**
     * Check normal configuration items
     * @param keyStr Configuration key
     * @param value Configuration value from Flutter
     * @param configMap Configuration map from SDK
     */
    private fun normalItemCheck(keyStr: String, value: Any?, configMap: Map<String, Any?>): Boolean {
        if (configMap.containsKey(keyStr)) {
            val configValue = configMap[keyStr]
            when {
                value is Number && configValue is Number -> {
                    val d1 = value.toDouble()
                    val d2 = configValue.toDouble()
                    if (kotlin.math.abs(d1 - d2) > EPSILON) {
                        return false // Exceeds error range, considered not equal
                    }
                }
                else -> {
                    if (!Objects.equals(value, configValue)) {
                        logNotMatch(keyStr, value, configValue)
                        return false
                    }
                }
            }
        }
        return true
    }

    /**
     * Log configuration mismatch
     * @param key Configuration key
     * @param flutterValue Value from Flutter
     * @param realValue Real value from SDK
     */
    private fun logNotMatch(key: String, flutterValue: Any?, realValue: Any?) {
        LogUtils.e(LOG_TAG, "key:$key, value:$flutterValue, config:$realValue, not match")
    }

    /**
     * Convert Flutter method call arguments
     * @param call Flutter method call
     * @return Converted arguments map
     */
    fun flutterArgsConvert(call: MethodCall): Map<String, Any?> {
        val method = call.method
        val argsObj = call.arguments
        if (argsObj !is Map<*, *>) {
            LogUtils.e(LOG_TAG, "$method: call invoke failed")
            return emptyMap()
        }

        @Suppress("UNCHECKED_CAST")
        val args = argsObj as Map<String, Any?>
        checkArguments(method, args)
        return args
    }

    /**
     * Check and log arguments
     * @param method Method name
     * @param args Arguments map
     */
    private fun checkArguments(method: String, args: Map<String, Any?>) {
        val builder = StringBuilder()
        builder.append("method:").append(method).append(" not set:[")
        for ((key, value) in args) {
            if (value == null) {
                builder.append(key).append(" ")
            }
        }
        builder.append("]")
        LogUtils.d(LOG_TAG, builder.toString())
    }
}