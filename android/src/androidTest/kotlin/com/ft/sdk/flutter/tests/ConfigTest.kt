package com.ft.sdk.flutter.tests

import com.ft.sdk.flutter.FTMobileAgentFlutter
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ALLOW_WEBVIEW_HOST
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_AUTO_SYNC
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_CLI_TOKEN
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_COMPRESS_INTAKE_REQUESTS
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_CUSTOM_SYNC_PAGE_SIZE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DATAKIT_URL
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DATAWAY_URL
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DATA_MODIFIER
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DB_CACHE_DISCARD
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DB_CACHE_LIMIT
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DEBUG
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DETECT_FREQUENCY
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_DEVICE_METRICS_MONITOR_TYPE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_APP_UI_BLOCK
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_CUSTOM_LOG
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_DATA_INTEGER_COMPATIBLE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_LIMIT_WITH_DB_SIZE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_LINK_RUM_DATA
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_NATIVE_AUTO_TRACE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_REMOTE_CONFIGURATION
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_TRACE_WEBVIEW
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_TRACK_NATIVE_APP_ANR
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_TRACK_NATIVE_CRASH
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_USER_ACTION
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_USER_RESOURCE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_USER_VIEW
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENABLE_USER_VIEW_IN_FRAGMENT
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ENV_TYPE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_ERROR_MONITOR_TYPE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_GLOBAL_CONTEXT
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_LINE_DATA_MODIFIER
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_LOG_CACHE_DISCARD
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_LOG_CACHE_LIMIT_COUNT
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_LOG_TYPE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_NATIVE_UI_BLOCK_DURATION_MS
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_PRINT_CUSTOM_LOG_TO_CONSOLE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_REMOTE_CONFIG_MINI_UPDATE_INTERVAL
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_RUM_APP_ID
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_RUM_CACHE_DISCARD
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_RUM_CACHE_LIMIT_COUNT
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_SAMPLE_RATE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_SERVICE_NAME
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_SESSION_ON_ERROR_SAMPLE_RATE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_SYNC_PAGE_SIZE
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_SYNC_SLEEP_TIME
import com.ft.sdk.flutter.FTMobileAgentFlutter.Companion.KEY_TRACE_TYPE
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Assert
import org.junit.Before
import org.junit.Test

open class ConfigTest {

    companion object {
        private const val FAKE_URL = "http://www.fake.url"
        private const val FAKE_TOKEN = "cli_xxx"

        private val SDK_FAKE_MAP: Map<String, Any?> = mapOf(
            KEY_DATAKIT_URL to FAKE_URL,
            KEY_DATAWAY_URL to FAKE_URL,
            KEY_CLI_TOKEN to FAKE_TOKEN,
            KEY_DEBUG to true,
            KEY_ENV_TYPE to "test",
            KEY_SERVICE_NAME to "testService",
            KEY_AUTO_SYNC to false,
            KEY_SYNC_PAGE_SIZE to 1,
            KEY_SYNC_SLEEP_TIME to 100,
            KEY_CUSTOM_SYNC_PAGE_SIZE to 100,
            KEY_COMPRESS_INTAKE_REQUESTS to true,
            KEY_ENABLE_DATA_INTEGER_COMPATIBLE to true,
            KEY_DB_CACHE_DISCARD to 1,
            KEY_ENABLE_LIMIT_WITH_DB_SIZE to true,
            KEY_DB_CACHE_LIMIT to 60 * 1024 * 1024,
            KEY_DATA_MODIFIER to mapOf("device_uuid" to "xxx"),
            KEY_LINE_DATA_MODIFIER to mapOf("view_url" to "xxx"),
            KEY_GLOBAL_CONTEXT to mapOf("test_key" to "test_value"),
            KEY_ENABLE_REMOTE_CONFIGURATION to true,
            KEY_REMOTE_CONFIG_MINI_UPDATE_INTERVAL to 100
        )

        private val SDK_FAKE_EMPTY_MAP = SDK_FAKE_MAP.keys.associateWith { null }

        private val SDK_RUM_FAKE_MAP: Map<String, Any?> = mapOf(
            KEY_RUM_APP_ID to "app_id",
            KEY_SAMPLE_RATE to 0.7,
            KEY_SESSION_ON_ERROR_SAMPLE_RATE to 1.0,
            KEY_ENABLE_USER_ACTION to true,
            KEY_ENABLE_USER_VIEW to true,
            KEY_ENABLE_USER_VIEW_IN_FRAGMENT to true,
            KEY_ENABLE_USER_RESOURCE to true,
            KEY_ENABLE_TRACK_NATIVE_APP_ANR to true,
            KEY_ENABLE_TRACK_NATIVE_CRASH to true,
            KEY_NATIVE_UI_BLOCK_DURATION_MS to 100,
            KEY_ENABLE_APP_UI_BLOCK to true,
            KEY_ERROR_MONITOR_TYPE to 2,
            KEY_GLOBAL_CONTEXT to mapOf("rum_key" to "rum_value"),
            KEY_DEVICE_METRICS_MONITOR_TYPE to 1,
            KEY_DETECT_FREQUENCY to 1,
            KEY_RUM_CACHE_LIMIT_COUNT to 10000,
            KEY_RUM_CACHE_DISCARD to 0,
            KEY_ENABLE_TRACE_WEBVIEW to true,
            KEY_ALLOW_WEBVIEW_HOST to listOf("fake1.host.com","fake2.host.com")
        )

        private val SDK_RUM_FAKE_EMPTY_MAP =
            SDK_RUM_FAKE_MAP.keys.associateWith { if (it != KEY_RUM_APP_ID) null else SDK_RUM_FAKE_MAP[it] }

        private val SDK_LOG_FAKE_MAP: Map<String, Any?> = mapOf(
            KEY_SAMPLE_RATE to 0.4,
            KEY_LOG_CACHE_DISCARD to 1,
            KEY_LOG_TYPE to listOf(0, 1),
            KEY_ENABLE_LINK_RUM_DATA to true,
            KEY_ENABLE_CUSTOM_LOG to true,
            KEY_PRINT_CUSTOM_LOG_TO_CONSOLE to true,
            KEY_LOG_CACHE_LIMIT_COUNT to 10000,
            KEY_GLOBAL_CONTEXT to mapOf("log_key" to "log_value")
        )

        private val SDK_LOG_FAKE_EMPTY_MAP = SDK_LOG_FAKE_MAP.keys.associateWith { null }

        private val SDK_TRACE_FAKE_MAP: Map<String, Any?> = mapOf(
            KEY_SAMPLE_RATE to 0.5,
            KEY_ENABLE_LINK_RUM_DATA to true,
            KEY_ENABLE_NATIVE_AUTO_TRACE to true,
            KEY_TRACE_TYPE to 1
        )

        private val SDK_TRACE_FAKE_EMPTY_MAP = SDK_TRACE_FAKE_MAP.keys.associateWith { null }
    }

    private val channel = FTMobileAgentFlutter()

    @Before
    fun setUp() {
        channel.setChancelDebug(true)
    }

    @Test
    fun sdkConfigTest() {
        val datakitMap = SDK_FAKE_MAP.filterNot {
            it.key == KEY_DATAWAY_URL || it.key == KEY_CLI_TOKEN || it.key == KEY_SYNC_PAGE_SIZE  }
        checkMap(FTMobileAgentFlutter.METHOD_CONFIG, datakitMap)

        val datawayMap =
            SDK_FAKE_MAP.filterNot { it.key == KEY_DATAKIT_URL || it.key == KEY_CLI_TOKEN || it.key == KEY_CUSTOM_SYNC_PAGE_SIZE  }
        checkMap(FTMobileAgentFlutter.METHOD_CONFIG, datawayMap)
    }

    @Test
    fun sdkConfigEmptyTest() {
        checkMap(FTMobileAgentFlutter.METHOD_CONFIG, SDK_FAKE_EMPTY_MAP)
    }

    @Test
    fun rumConfigTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_RUM_CONFIG, SDK_RUM_FAKE_MAP)
    }

    @Test
    fun rumConfigEmptyTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_RUM_CONFIG, SDK_RUM_FAKE_EMPTY_MAP)
    }

    @Test
    fun logConfigTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_LOG_CONFIG, SDK_LOG_FAKE_MAP)
    }

    @Test
    fun logConfigEmptyTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_LOG_CONFIG, SDK_LOG_FAKE_EMPTY_MAP)
    }

    @Test
    fun traceConfigTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_TRACE_CONFIG, SDK_TRACE_FAKE_MAP)
    }

    @Test
    fun traceConfigEmptyTest() {
        setFakeSdkConfig()
        checkMap(FTMobileAgentFlutter.METHOD_TRACE_CONFIG, SDK_TRACE_FAKE_EMPTY_MAP)
    }

    private fun setFakeSdkConfig() {
        channel.onMethodCall(
            MethodCall(
                FTMobileAgentFlutter.METHOD_CONFIG, mapOf(
                    KEY_DATAKIT_URL to FAKE_URL,
                    KEY_DEBUG to true
                )
            ),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Assert.assertTrue(result as Boolean)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Assert.fail()
                }

                override fun notImplemented() {
                    Assert.fail()
                }
            })
    }


    private fun checkMap(method: String, map: Map<String, Any?>) {
        channel.onMethodCall(
            MethodCall(method, map),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Assert.assertTrue(result as Boolean)
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Assert.fail()
                }

                override fun notImplemented() {
                    Assert.fail()
                }
            })
    }
}