package com.cloudcare.ft.mobile.sdk.agent

import android.app.Application
import android.view.ViewGroup
import androidx.annotation.NonNull
import com.ft.sdk.FTLogger
import com.ft.sdk.FTSDKConfig
import com.ft.sdk.FTSdk
import com.ft.sdk.garble.bean.Status
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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
        const val METHOD_CONFIG = "ftConfig"
        const val METHOD_LOGGING = "ftLogging"
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            METHOD_CONFIG -> {
                val metricsUrl: String = call.argument<String>("metricsUrl")!!
                FTSdk.install(FTSDKConfig.builder(metricsUrl).setDebug(true))
                result.success(null)
            }
            METHOD_LOGGING -> {
                val content: String = call.argument<String>("content")!!
                val status: Status = when (call.argument<Int>("status")) {
                    0 -> Status.INFO
                    1 -> Status.WARNING
                    2 -> Status.ERROR
                    3 -> Status.CRITICAL
                    4 -> Status.OK
                    else -> Status.INFO
                }

                FTLogger.getInstance().logBackground(content, status)
            }

            else -> {
                result.notImplemented()
            }
        }
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
