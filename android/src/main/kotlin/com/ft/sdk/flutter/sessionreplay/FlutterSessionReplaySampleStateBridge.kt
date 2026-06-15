package com.ft.sdk.flutter.sessionreplay

import android.content.Context
import android.os.Handler
import com.ft.sdk.SessionReplayManager
import com.ft.sdk.feature.Feature
import com.ft.sdk.feature.FeatureContextUpdateReceiver
import com.ft.sdk.garble.utils.LogUtils
import com.ft.sdk.sessionreplay.internal.persistence.TrackingConsent
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class FlutterSessionReplaySampleStateBridge(
    binaryMessenger: BinaryMessenger,
    private val handler: Handler,
    private val logTag: String
) {
    private val channel = MethodChannel(binaryMessenger, SESSION_REPLAY_STATE_CHANNEL)
    private val sampleStateLock = Any()
    private var contextReceiver: FeatureContextUpdateReceiver? = null
    private var lastSampled: Boolean? = null
    private var lastSampledForErrorReplay: Boolean? = null

    fun register() {
        try {
            val manager = SessionReplayManager.get()
            registerFlutterSessionReplayFeature(manager)
            if (contextReceiver == null) {
                val receiver = FeatureContextUpdateReceiver { source, context ->
                    if (source != Feature.SESSION_REPLAY_FEATURE_NAME && source != FEATURE_SESSION_REPLAY) {
                        return@FeatureContextUpdateReceiver
                    }
                    if (!context.containsKey(KEY_SESSION_REPLAY_IS_ENABLED) &&
                        !context.containsKey(KEY_SESSION_REPLAY_IS_ENABLED_ON_ERROR)
                    ) {
                        return@FeatureContextUpdateReceiver
                    }
                    val sampled = booleanValue(context[KEY_SESSION_REPLAY_IS_ENABLED]) ?: false
                    val sampledForErrorReplay =
                        booleanValue(context[KEY_SESSION_REPLAY_IS_ENABLED_ON_ERROR]) ?: false
                    notify(
                        sampled,
                        sampledForErrorReplay,
                        force = false
                    )
                }
                contextReceiver = receiver
                manager.setContextUpdateReceiver(FEATURE_FLUTTER_SESSION_REPLAY, receiver)
            }
        } catch (e: Throwable) {
            LogUtils.w(
                logTag,
                "[FlutterSRBridge] register sample state receiver failed: ${e.javaClass.simpleName}: ${e.message}"
            )
        }
    }

    fun notifyCurrentState() {
        val consent = try {
            SessionReplayManager.get().getConsentProvider()
        } catch (e: Throwable) {
            LogUtils.w(
                logTag,
                "[FlutterSRBridge] read current sample state failed: ${e.javaClass.simpleName}: ${e.message}"
            )
            null
        }
        when (consent) {
            TrackingConsent.GRANTED -> notify(
                sampled = true,
                sampledForErrorReplay = false,
                force = true
            )

            TrackingConsent.SAMPLED_ON_ERROR_SESSION -> notify(
                sampled = true,
                sampledForErrorReplay = true,
                force = true
            )

            else -> {}
        }
    }

    fun notify(
        sampled: Boolean,
        sampledForErrorReplay: Boolean,
        force: Boolean
    ) {
        val shouldNotify = synchronized(sampleStateLock) {
            val changed = lastSampled != sampled ||
                lastSampledForErrorReplay != sampledForErrorReplay
            if (force || changed) {
                lastSampled = sampled
                lastSampledForErrorReplay = sampledForErrorReplay
                true
            } else {
                false
            }
        }
        if (!shouldNotify) {
            return
        }
        handler.post {
            channel.invokeMethod(
                METHOD_SESSION_REPLAY_SAMPLE_STATE_CHANGED,
                mapOf(
                    "sampled" to sampled,
                    "sampledForErrorReplay" to sampledForErrorReplay
                )
            )
        }
    }

    fun dispose() {
        val receiver = contextReceiver ?: return
        try {
            SessionReplayManager.get().removeContextUpdateReceiver(
                FEATURE_FLUTTER_SESSION_REPLAY,
                receiver
            )
        } catch (e: Throwable) {
            LogUtils.w(
                logTag,
                "[FlutterSRBridge] unregister sample state receiver failed: ${e.javaClass.simpleName}: ${e.message}"
            )
        }
        contextReceiver = null
        synchronized(sampleStateLock) {
            lastSampled = null
            lastSampledForErrorReplay = null
        }
    }

    private fun registerFlutterSessionReplayFeature(manager: SessionReplayManager) {
        if (manager.getFeature(FEATURE_FLUTTER_SESSION_REPLAY) != null) {
            return
        }
        manager.registerFeature(object : Feature {
            override fun getName(): String = FEATURE_FLUTTER_SESSION_REPLAY

            override fun onInitialize(context: Context?) {}

            override fun onStop() {}
        })
    }

    private fun booleanValue(value: Any?): Boolean? {
        return when (value) {
            is Boolean -> value
            is Number -> value.toInt() != 0
            is String -> when {
                value.equals("true", ignoreCase = true) -> true
                value.equals("false", ignoreCase = true) -> false
                else -> null
            }

            else -> null
        }
    }

    private companion object {
        const val METHOD_SESSION_REPLAY_SAMPLE_STATE_CHANGED = "ftSessionReplaySampleStateChanged"
        const val SESSION_REPLAY_STATE_CHANNEL = "ft_mobile_agent_flutter/session_replay"
        const val FEATURE_FLUTTER_SESSION_REPLAY = "flutter-session-replay"
        const val FEATURE_SESSION_REPLAY = "session-replay"
        const val KEY_SESSION_REPLAY_IS_ENABLED = "session_replay_is_enabled"
        const val KEY_SESSION_REPLAY_IS_ENABLED_ON_ERROR = "session_replay_is_enabled_on_error"
    }
}
