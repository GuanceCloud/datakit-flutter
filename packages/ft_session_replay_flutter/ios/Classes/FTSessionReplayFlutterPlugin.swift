import Flutter
import UIKit
import FTMobileSDK

public class FTSessionReplayFlutterPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var sessionReplayStateChannel: FlutterMethodChannel?
    private let sessionReplayBridge: FTSessionReplayBridge = FTDefaultSessionReplayBridge()

    static let METHOD_SESSION_REPLAY_CONFIG = "ftSessionReplayConfig"
    static let METHOD_SESSION_REPLAY_GET_RUM_CONTEXT = "ftSessionReplayGetRumContext"
    static let METHOD_SESSION_REPLAY_SET_HAS_REPLAY = "ftSessionReplaySetHasReplay"
    static let METHOD_SESSION_REPLAY_SET_RECORD_COUNT = "ftSessionReplaySetRecordCount"
    static let METHOD_SESSION_REPLAY_WRITE_SEGMENT = "ftSessionReplayWriteSegment"
    static let METHOD_SESSION_REPLAY_TELEMETRY_DEBUG = "ftSessionReplayTelemetryDebug"
    static let METHOD_SESSION_REPLAY_TELEMETRY_ERROR = "ftSessionReplayTelemetryError"
    static let METHOD_SESSION_REPLAY_SAVE_IMAGE_RESOURCE = "ftSessionReplaySaveImageResource"
    static let METHOD_SESSION_REPLAY_SAMPLE_STATE_CHANGED = "ftSessionReplaySampleStateChanged"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "ft_session_replay_flutter",
            binaryMessenger: registrar.messenger()
        )
        let sessionReplayStateChannel = FlutterMethodChannel(
            name: "ft_session_replay_flutter/session_replay",
            binaryMessenger: registrar.messenger()
        )
        let instance = FTSessionReplayFlutterPlugin()
        instance.channel = channel
        instance.sessionReplayStateChannel = sessionReplayStateChannel
        instance.sessionReplayBridge.setSampleStateChangedHandler { [weak instance] context in
            instance?.sessionReplayStateChannel?.invokeMethod(
                FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_SAMPLE_STATE_CHANGED,
                arguments: context
            )
        }
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        var context = Dictionary<String, Any>()
        if let arguments = call.arguments as? Dictionary<String, Any> {
            context = arguments
        }
        switch call.method {
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_CONFIG:
            sessionReplayBridge.config(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_GET_RUM_CONTEXT:
            result(sessionReplayBridge.currentRUMContext())
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_SET_HAS_REPLAY:
            sessionReplayBridge.setHasReplay(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_SET_RECORD_COUNT:
            sessionReplayBridge.setRecordCount(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_WRITE_SEGMENT:
            sessionReplayBridge.writeSegment(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_TELEMETRY_DEBUG:
            sessionReplayBridge.telemetryDebug(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_TELEMETRY_ERROR:
            sessionReplayBridge.telemetryError(context)
            result(nil)
        case FTSessionReplayFlutterPlugin.METHOD_SESSION_REPLAY_SAVE_IMAGE_RESOURCE:
            result(sessionReplayBridge.saveImageResource(context))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
