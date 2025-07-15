import UIKit
import Flutter
//import FTMobileSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      // Native hybrid initialization
//      var config:FTMobileConfig = FTMobileConfig.init(datakitUrl: "http://datakit.url")
//      config.enableSDKDebugLog = true
//      FTMobileAgent.start(withConfigOptions: config)
//      let rum = FTRumConfig(appid:"ios_app_id")
//      rum.enableTrackAppANR = true
//      rum.enableTraceUserView = true
//      rum.enableTraceUserAction = true
//      rum.enableTraceUserResource = true
//      rum.enableTrackAppCrash = true
//      rum.enableTrackAppFreeze = true
//      rum.deviceMetricsMonitorType = .all
//      rum.errorMonitorType = .all
//      FTMobileAgent.sharedInstance().startRum(withConfigOptions: rum)
//      
//      let trace = FTTraceConfig()
//      trace.enableAutoTrace = true
//      trace.enableLinkRumData = true
//      FTMobileAgent.sharedInstance().startTrace(withConfigOptions: trace)
//      
//      let logger = FTLoggerConfig()
//      logger.enableCustomLog = true
//      logger.enableLinkRumData = true
//      logger.printCustomLogToConsole = true
//      FTMobileAgent.sharedInstance().startLogger(withConfigOptions: logger)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

}
