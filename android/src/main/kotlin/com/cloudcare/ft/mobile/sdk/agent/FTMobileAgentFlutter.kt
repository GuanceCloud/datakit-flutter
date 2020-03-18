package com.cloudcare.ft.mobile.sdk.agent

import android.app.Application
import androidx.annotation.NonNull
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTSdk
import com.ft.sdk.FTTrack
import com.ft.sdk.garble.SyncCallback
import com.ft.sdk.garble.bean.TrackBean
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

        const val METHOD_CONFIG = "ftConfig"
        const val METHOD_TRACK = "ftTrack"
        const val METHOD_TRACK_LIST = "ftTrackList"
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
                val datakitUUID: String? = call.argument<String>("datakitUUID")
                ftConfig(serverUrl, akId, akSecret, datakitUUID)
                result.success(null)

            }
            METHOD_TRACK -> {
                val measurement = call.argument<String>("measurement")!!
                val tags = call.argument<Map<String, Any>>("tags")
                val fields = call.argument<Map<String, Any>>("fields")
                result.success(runBlocking { return@runBlocking ftTrackSync(measurement, tags, fields) })
            }
            METHOD_TRACK_LIST -> {
                val list = call.argument<List<Map<String, Any?>>>("list")
                result.success(runBlocking { return@runBlocking list?.let { ftTrackListSync(it) } })
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun ftConfig(serverUrl: String, akId: String?, akSecret: String?, datakitUUID: String?) {
        val enableRequestSigning = akId != null && akSecret != null
        val config = FTSDKConfig(serverUrl, enableRequestSigning, akId, akSecret)
        if (datakitUUID != null) {
            config.setXDataKitUUID(datakitUUID)
        }
        FTSdk.install(config)
    }

    private suspend fun ftTrackSync(measurement: String, tags: Map<String, Any?>?, fields: Map<String, Any?>?): Boolean = suspendCoroutine { cont ->
        ftTrack(measurement, tags, fields, SyncCallback {

            cont.resume(it)
        })
    }

    private suspend fun ftTrackListSync(array: List<Map<String, Any?>>): Boolean = suspendCoroutine { cont ->
        ftTrackList(array, SyncCallback {

            cont.resume(it)
        })
    }


    private fun ftTrack(measurement: String, tags: Map<String, Any?>?, fields: Map<String, Any?>?, callback: SyncCallback) {
        if (tags != null) {
            FTTrack.getInstance().trackImmediate(measurement, JSONObject(tags), JSONObject(fields), callback)
        } else {
            FTTrack.getInstance().trackImmediate(measurement, JSONObject(), JSONObject(fields), callback)
        }
    }

    private fun ftTrackList(array: List<Map<String, Any?>>, callback: SyncCallback) {
        val beans: MutableList<TrackBean> = mutableListOf()
        array.forEach {
            val measurement = it["measurement"] as String
            val fields = it["fields"] as Map<*, *>
            var tags: Map<*, *>? = null
            if (it["tags"] != null) {
                tags = it["tags"] as Map<*, *>

            }
            beans.add(TrackBean(measurement, if (tags == null) null else JSONObject(tags), JSONObject(fields)))
        }
        FTTrack.getInstance().trackImmediate(beans, callback)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
