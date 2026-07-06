package com.ft.sdk.flutter.sessionreplay

import android.app.Activity
import android.os.Handler
import android.os.Looper
import com.ft.sdk.FTSdk
import com.ft.sdk.SessionReplayManager
import com.ft.sdk.garble.utils.Constants
import com.ft.sdk.garble.utils.LogUtils
import com.ft.sdk.sessionreplay.FTSessionReplayConfig
import com.ft.sdk.sessionreplay.FTSessionReplayFlutterBridgeConfig
import com.ft.sdk.sessionreplay.ImagePrivacy
import com.ft.sdk.sessionreplay.SessionReplayInternalCallback
import com.ft.sdk.sessionreplay.TextAndInputPrivacy
import com.ft.sdk.sessionreplay.TouchPrivacy
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FTSessionReplayFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var sessionReplaySampleStateBridge: FlutterSessionReplaySampleStateBridge? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        val mainHandler = Handler(Looper.getMainLooper())
        sessionReplaySampleStateBridge = FlutterSessionReplaySampleStateBridge(
            flutterPluginBinding.binaryMessenger,
            mainHandler,
            LOG_TAG
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        sessionReplaySampleStateBridge?.dispose()
        sessionReplaySampleStateBridge = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_SESSION_REPLAY_CONFIG -> configureSessionReplay(call, result)

            METHOD_SESSION_REPLAY_GET_RUM_CONTEXT -> {
                result.success(invokeSessionReplayManager("getCurrentFlutterRumContext"))
            }

            METHOD_SESSION_REPLAY_SET_HAS_REPLAY -> {
                val viewId: String? = call.argument("viewId")
                val hasReplay: Boolean = call.argument<Boolean>("hasReplay") ?: true
                if (viewId != null) {
                    invokeSessionReplayManager(
                        "setFlutterHasReplay",
                        arrayOf(String::class.java, Boolean::class.javaPrimitiveType!!),
                        viewId,
                        hasReplay
                    )
                }
                result.success(null)
            }

            METHOD_SESSION_REPLAY_SET_RECORD_COUNT -> {
                val viewId: String? = call.argument("viewId")
                val count: Number? = call.argument("count")
                if (viewId != null && count != null) {
                    invokeSessionReplayManager(
                        "setFlutterRecordCount",
                        arrayOf(String::class.java, Long::class.javaPrimitiveType!!),
                        viewId,
                        count.toLong()
                    )
                }
                result.success(null)
            }

            METHOD_SESSION_REPLAY_WRITE_SEGMENT -> {
                val viewId: String? = call.argument("viewId")
                val segment: String? = call.argument("segment")
                if (viewId != null && segment != null) {
                    invokeSessionReplayManager(
                        "writeFlutterSegment",
                        arrayOf(String::class.java, String::class.java),
                        segment,
                        viewId
                    )
                }
                result.success(null)
            }

            METHOD_SESSION_REPLAY_TELEMETRY_DEBUG -> {
                val message: String? = call.argument("message")
                if (message != null) {
                    LogUtils.d(LOG_TAG, message)
                }
                result.success(null)
            }

            METHOD_SESSION_REPLAY_TELEMETRY_ERROR -> {
                val message: String? = call.argument("message")
                val stack: String? = call.argument("stack")
                if (message != null) {
                    LogUtils.e(LOG_TAG, message + if (stack != null) "\n$stack" else "")
                }
                result.success(null)
            }

            METHOD_SESSION_REPLAY_SAVE_IMAGE_RESOURCE -> {
                val bytes: ByteArray? = call.argument("bytes")
                val width: Int? = call.argument("width")
                val height: Int? = call.argument("height")
                val resourceId = if (bytes != null && width != null && height != null) {
                    invokeSessionReplayManager(
                        "saveFlutterImageResource",
                        arrayOf(
                            ByteArray::class.java,
                            Int::class.javaPrimitiveType!!,
                            Int::class.javaPrimitiveType!!
                        ),
                        bytes,
                        width,
                        height
                    )
                } else {
                    null
                }
                result.success(resourceId)
            }

            else -> result.notImplemented()
        }
    }

    private fun configureSessionReplay(call: MethodCall, result: MethodChannel.Result) {
        val sessionReplayConfig = FTSessionReplayConfig()
        val sampleRate: Number? = call.argument<Number>(KEY_SAMPLE_RATE)
        val sessionReplayOnErrorSampleRate: Number? =
            call.argument<Number>(KEY_SESSION_REPLAY_ON_ERROR_SAMPLE_RATE)
        val touchPrivacy: Number? = call.argument<Number>(KEY_TOUCH_PRIVACY)
        val textAndInputPrivacy: Number? = call.argument<Number>(KEY_TEXT_AND_INPUT_PRIVACY)
        val imagePrivacy: Number? = call.argument<Number>(KEY_IMAGE_PRIVACY)
        val enableLinkRUMKeys: List<String>? = call.argument(KEY_ENABLE_LINK_RUM_KEYS)

        if (sampleRate != null) {
            sessionReplayConfig.setSampleRate(sampleRate.toFloat())
        }
        if (sessionReplayOnErrorSampleRate != null) {
            sessionReplayConfig.setSessionReplayOnErrorSampleRate(
                sessionReplayOnErrorSampleRate.toFloat()
            )
        }
        if (touchPrivacy != null) {
            val value = TouchPrivacy.values().getOrNull(touchPrivacy.toInt())
            if (value == null) {
                result.error("INVALID_ARGUMENT", "Invalid touchPrivacy: $touchPrivacy", null)
                return
            }
            sessionReplayConfig.setTouchPrivacy(value)
        }
        if (textAndInputPrivacy != null) {
            val value = TextAndInputPrivacy.values().getOrNull(textAndInputPrivacy.toInt())
            if (value == null) {
                result.error(
                    "INVALID_ARGUMENT",
                    "Invalid textAndInputPrivacy: $textAndInputPrivacy",
                    null
                )
                return
            }
            sessionReplayConfig.setTextAndInputPrivacy(value)
        }
        if (imagePrivacy != null) {
            val value = ImagePrivacy.values().getOrNull(imagePrivacy.toInt())
            if (value == null) {
                result.error("INVALID_ARGUMENT", "Invalid imagePrivacy: $imagePrivacy", null)
                return
            }
            sessionReplayConfig.setImagePrivacy(value)
        }
        if (enableLinkRUMKeys != null) {
            sessionReplayConfig.enableLinkRUMKeys(enableLinkRUMKeys.toTypedArray())
        }
        sessionReplayConfig.setInternalCallback(object : SessionReplayInternalCallback {
            override fun getCurrentActivity(): Activity? {
                return activity
            }
        })
        if (!FTSessionReplayFlutterBridgeConfig.markExternalRecorderMode(sessionReplayConfig)) {
            LogUtils.w(
                LOG_TAG,
                "[FlutterSRBridge] external recorder mode is unavailable. " +
                    "Please upgrade ft-session-replay to a compatible version."
            )
            sessionReplaySampleStateBridge?.notify(
                sampled = false,
                sampledForErrorReplay = false,
                force = true
            )
            result.success(null)
            return
        }

        FTSdk.initSessionReplayConfig(sessionReplayConfig)
        sessionReplaySampleStateBridge?.register()
        sessionReplaySampleStateBridge?.notifyCurrentState()
        result.success(null)
    }

    private fun invokeSessionReplayManager(
        methodName: String,
        parameterTypes: Array<Class<*>> = emptyArray(),
        vararg args: Any?
    ): Any? {
        return try {
            val manager = SessionReplayManager.get()
            val method = manager.javaClass.getMethod(methodName, *parameterTypes)
            method.invoke(manager, *args)
        } catch (e: Throwable) {
            LogUtils.w(LOG_TAG, "Session Replay native bridge method unavailable: $methodName")
            null
        }
    }

    companion object {
        const val LOG_TAG = "${Constants.LOG_TAG_PREFIX}FTSessionReplayFlutterPlugin"
        private const val CHANNEL_NAME = "ft_session_replay_flutter"

        const val METHOD_SESSION_REPLAY_CONFIG = "ftSessionReplayConfig"
        const val METHOD_SESSION_REPLAY_GET_RUM_CONTEXT = "ftSessionReplayGetRumContext"
        const val METHOD_SESSION_REPLAY_SET_HAS_REPLAY = "ftSessionReplaySetHasReplay"
        const val METHOD_SESSION_REPLAY_SET_RECORD_COUNT = "ftSessionReplaySetRecordCount"
        const val METHOD_SESSION_REPLAY_WRITE_SEGMENT = "ftSessionReplayWriteSegment"
        const val METHOD_SESSION_REPLAY_TELEMETRY_DEBUG = "ftSessionReplayTelemetryDebug"
        const val METHOD_SESSION_REPLAY_TELEMETRY_ERROR = "ftSessionReplayTelemetryError"
        const val METHOD_SESSION_REPLAY_SAVE_IMAGE_RESOURCE = "ftSessionReplaySaveImageResource"

        const val KEY_SAMPLE_RATE = "sampleRate"
        const val KEY_SESSION_REPLAY_ON_ERROR_SAMPLE_RATE = "sessionReplayOnErrorSampleRate"
        const val KEY_TOUCH_PRIVACY = "touchPrivacy"
        const val KEY_TEXT_AND_INPUT_PRIVACY = "textAndInputPrivacy"
        const val KEY_IMAGE_PRIVACY = "imagePrivacy"
        const val KEY_ENABLE_LINK_RUM_KEYS = "enableLinkRUMKeys"
    }
}
