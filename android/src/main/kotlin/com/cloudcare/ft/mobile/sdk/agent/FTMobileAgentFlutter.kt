package com.cloudcare.ft.mobile.sdk.agent

import android.app.Application
import androidx.annotation.NonNull
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTSdk
import com.ft.sdk.FTTrack
import com.ft.sdk.garble.SyncCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.runBlocking
import org.json.JSONObject
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/** AgentPlugin */
public class FTMobileAgentFlutter : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var application: Application


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ft_mobile_agent_flutter")
        channel.setMethodCallHandler(this)
        application = flutterPluginBinding.applicationContext as Application
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
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "ft_mobile_agent_flutter")
            channel.setMethodCallHandler(FTMobileAgentFlutter())
        }

        const val METHOD_CONFIG = "ft_config"
        const val METHOD_TRACK = "ft_track"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            METHOD_CONFIG -> {
                val serverUrl: String = call.argument<String>("serverUrl")!!
                val akId: String? = call.argument<String>("akId")
                val akSecret: String? = call.argument<String>("akSecret")
                ftConfig(serverUrl, akId, akSecret)
                result.success(null)

            }
            METHOD_TRACK -> {
                val field = call.argument<String>("field")!!
                val tags = call.argument<Map<String, Any>>("tags")
                val values = call.argument<Map<String, Any>>("values")
                result.success(runBlocking { return@runBlocking ftTrackSync(field, tags, values) })
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun ftConfig(serverUrl: String, akId: String?, akSecret: String?) {
        val enableRequestSigning = akId != null && akSecret != null
        val config = FTSDKConfig(serverUrl, enableRequestSigning, akId, akSecret)
        FTSdk.install(config, application)
    }

    private suspend fun ftTrackSync(field: String, tags: Map<String, Any?>?, values: Map<String, Any?>?): Boolean = suspendCoroutine { cont ->
        ftTrack(field, tags, values, SyncCallback {

            cont.resume(it)
        })
    }


    private fun ftTrack(field: String, tags: Map<String, Any?>?, values: Map<String, Any?>?, callback: SyncCallback) {
        if (tags != null) {
            FTTrack.getInstance().trackImmediate(field, JSONObject(tags), JSONObject(values), callback)
        } else {
            FTTrack.getInstance().trackImmediate(field, JSONObject(), JSONObject(values), callback)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
