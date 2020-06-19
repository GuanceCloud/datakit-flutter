package com.cloudcare.ft.mobile.sdk.agent

import android.app.Application
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.ft.sdk.*
import com.ft.sdk.garble.SyncCallback
import com.ft.sdk.garble.bean.TrackBean
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject

/** AgentPlugin */
public class FTMobileAgentFlutter : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var application: Application
    private var viewGroup: ViewGroup? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "ft_mobile_agent_flutter")
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
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "ft_mobile_agent_flutter")
            channel.setMethodCallHandler(FTMobileAgentFlutter())
        }

        const val METHOD_CONFIG = "ftConfig"
        const val METHOD_TRACK = "ftTrack"
        const val METHOD_TRACK_LIST = "ftTrackList"
        const val METHOD_TRACK_BACKGROUND = "ftTrackBackground"
        const val METHOD_BIND_USER = "ftBindUser"
        const val METHOD_UNBIND_USER = "ftUnBindUser"
        const val METHOD_STOP_SDK = "ftStopSdk"
        const val METHOD_START_LOCATION = "ftStartLocation"
        const val METHOD_START_MONITOR = "ftStartMonitor"
        const val METHOD_STOP_MONITOR = "ftStopMonitor"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_CONFIG -> {
                val serverUrl: String = call.argument<String>("serverUrl")!!
                val akId: String? = call.argument<String>("akId")
                val akSecret: String? = call.argument<String>("akSecret")
                val datakitUUID: String? = call.argument<String>("datakitUUID")
                val enableLog: Boolean? = call.argument<Boolean>("enableLog")
                val needBindUser: Boolean? = call.argument<Boolean>("needBindUser")
                val monitorType: Int? = call.argument<Int>("monitorType")
                val useGeoKey: Boolean? = call.argument<Boolean>("useGeoKey")
                val geoKey: String? = call.argument<String>("geoKey")
                val product: String? = call.argument<String>("product")
                val token: String? = call.argument<String>("token")
                ftConfig(serverUrl, akId, akSecret, datakitUUID, enableLog, needBindUser, monitorType, useGeoKey, geoKey, product, token)
                if (monitorType?.or(MonitorType.ALL) == monitorType || monitorType?.or(MonitorType.GPU) == monitorType) {
                    FTSdk.get().setGpuRenderer(viewGroup)
                }
                result.success(null)
            }
            METHOD_TRACK -> {
                val measurement = call.argument<String>("measurement")!!
                val tags = call.argument<Map<String, Any>>("tags")
                val fields = call.argument<Map<String, Any>>("fields")
                ftTrackSync(result, measurement, tags, fields)
            }
            METHOD_TRACK_LIST -> {
                val list = call.argument<List<Map<String, Any?>>>("list")
                list?.let { ftTrackListSync(result, it) }
            }

            METHOD_TRACK_BACKGROUND -> {
                val measurement = call.argument<String>("measurement")!!
                val fields = call.argument<Map<String, Any>>("fields")!!
                val tags = call.argument<Map<String, Any>>("tags")
                val tagsJS = if (tags != null) JSONObject(tags) else null
                FTTrack.getInstance().trackBackground(measurement, tagsJS, JSONObject(fields))
                result.success(null)
            }
            METHOD_BIND_USER -> {
                val name = call.argument<String>("name")!!
                val id = call.argument<String>("id")!!
                val extras = call.argument<Map<String, Any>>("extras")
                ftBindUser(name, id, extras)
                result.success(null)
            }
            METHOD_UNBIND_USER -> {
                FTSdk.get().unbindUserData()
                result.success(null)
            }
            METHOD_STOP_SDK -> {
                FTSdk.get().shutDown()
                result.success(null)
            }
            METHOD_START_LOCATION -> {
                val geoKey = call.argument<String>("geoKey")
                FTSdk.startLocation(geoKey) { code, response ->
                    result.success(mapOf("code" to code, "message" to response))
                }
            }
            METHOD_START_MONITOR -> {
                val geoKey = call.argument<String>("geoKey")
                val useGeoKey = call.argument<Boolean>("useGeoKey")
                val monitorType = call.argument<Int>("monitorType")
                val period = call.argument<Int>("period")
                geoKey?.let {
                    FTMonitor.get().setGeoKey(it)
                }
                useGeoKey?.let {
                    FTMonitor.get().setUseGeoKey(useGeoKey)
                }
                monitorType?.let {
                    FTMonitor.get().setMonitorType(it)
                }
                period?.let {
                    FTMonitor.get().setPeriod(it)
                }
                FTMonitor.get().start()
                result.success(null)
            }

            METHOD_STOP_MONITOR -> {
                FTMonitor.get().release()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun ftConfig(serverUrl: String, akId: String?, akSecret: String?, datakitUUID: String?,
                         enableLog: Boolean?, needBindUser: Boolean?, monitorType: Int?, useGeoKey: Boolean?,
                         geoKey: String?, product: String?, token: String?) {
        val enableRequestSigning = akId != null && akSecret != null
        val config = FTSDKConfig(serverUrl, enableRequestSigning, akId, akSecret)
        if (datakitUUID != null) {
            config.setXDataKitUUID(datakitUUID)
        }
        if (monitorType != null) {
            config.setMonitorType(monitorType)
        }
        config.apply {
            isDebug = enableLog ?: false
            isNeedBindUser = needBindUser ?: false
            token?.let {
                setDataWayToken(token)
            }
            useGeoKey?.let { use ->
                geoKey?.let { key ->
                    setGeoKey(use, key)
                }
            }
        }

        FTSdk.install(config)
    }

    private fun ftTrackSync(result: Result, measurement: String, tags: Map<String, Any?>?,
                            fields: Map<String, Any?>?) {
        GlobalScope.launch {
            ftTrack(measurement, tags, fields, SyncCallback { code, response ->
                val map = mapOf("code" to code, "response" to response)
                GlobalScope.launch(Dispatchers.Main) {
                    result.success(map)
                }
            })
        }
    }

    private fun ftTrackListSync(result: Result, array: List<Map<String, Any?>>) {
        GlobalScope.launch {
            ftTrackList(array, SyncCallback { code, response ->
                val map = mapOf("code" to code, "response" to response)
                GlobalScope.launch(Dispatchers.Main) {
                    result.success(map)
                }
            })
        }
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

    private fun ftBindUser(name: String, id: String, extras: Map<String, Any?>?) {
        FTSdk.get().bindUserData(name, id, JSONObject(extras))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
