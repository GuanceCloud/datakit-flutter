> Related SDK update content
> * [Android](https://github.com/TrueWatchTech/datakit-android/blob/dev/ft-sdk/CHANGELOG.md) 
> * [iOS ](https://github.com/TrueWatchTech/datakit-ios/blob/develop/CHANGELOG.md)

## 0.5.7-dev.3
* Android: Handling Missing Classes When Integrating SDKs in Android Release Builds

## 0.5.7-dev.2
* Android: fixing the issue where the Property is lost when calling startAction.
* Added addAction API to support high-frequency invocation scenarios, without associating
 data with Resource, LongTask, or Error events.
* Compatible with Android ft-native 1.1.2
---

## 0.5.7-dev.1
* Added `FTMobileFlutter.sdkConfig(enableRemoteConfiguration,remoteConfigMiniUpdateInterval)`,
  support enabling remote conditional configuration through `enableRemoteConfiguration = true`, and after enabling remote control,
  set minimum update interval through `remoteConfigMiniUpdateInterval`
* Added `FTRUMManager.setConfig(enableTraceWebView,allowWebViewHost)`, support configuring through enableTraceWebView
  whether to enable WebView data collection through Android SDK, control host addresses that need to be filtered through allowWebViewHost
* Compatible with iOS 1.5.17 version, compatible with Android ft-sdk 1.6.12
---
## 0.5.6+2
* After FTMobileFlutter.sdkConfig(dataModifier), caused issues with null data not being collected
* Fixed iOS RUM sampleRate, sessionOnErrorSampleRate, Log sampleRate, Trace sampleRate
  transmission failure issues in Flutter channel
---
## 0.5.6
* Added `FTRUMManager().setConfig(sessionOnErrorSampleRate)` to support error sampling, when not sampled by setSamplingRate,
  can sample RUM data from 1 minute before when errors occur
* Added `FTMobileFlutter.sdkConfig(dataModifier, lineDataModifier)` to support data write replacement and data desensitization
* Compatible with iOS 1.5.16 version, compatible with Android ft-sdk 1.6.11
---

## 0.5.5-pre.1
* Added FTRUMManager().setConfig(sessionOnErrorSampleRate) to support error sampling, when not sampled by setSamplingRate,
  can sample RUM data from 1 minute before when errors occur
* Added FTMobileFlutter.sdkConfig(dataModifier, lineDataModifier) to support data write replacement and data desensitization
* Compatible with iOS 1.5.16 version, compatible with Android ft-sdk 1.6.11

---
## 0.5.4-pre.1
* Compatible with iOS 1.5.14 version, compatible with Android ft-sdk 1.6.9
* FTMobileFlutter.setConfig(enableDataIntegerCompatible) enabled by default

---
## 0.5.3-pre.4
* Compatible with iOS 1.5.12 version

---

## 0.5.3-pre.3
* Compatible with iOS 1.5.11 version

---

## 0.5.3-pre.2
* Optimized FTHttpOverrideConfig configuration method, support configuration independent of SDK Config
* Support filtering URLs that don't need collection through FTRUMManager.sdkConfig(inTakeUrl)
* Optimized Resource collection resourceSize calculation method

---

## 0.5.3-dev.1
* Support limiting RUM data cache entry count through `FTRUMManager.sdkConfig(rumCacheLimitCount,rumCacheDiscard)`, 
  default 100_000
* Support setting total cache size limit through `FTMobileFlutter.sdkConfig(enableLimitWithDbSize,dbCacheLimit,dbCacheDiscard)`, 
  after enabling `FTRUMManager.sdkConfig(rumCacheLimitCount)`, `FTLogger.logConfig(logCacheLimitCount)`
* Compatible with Android ft-sdk 1.6.7 content, compatible with iOS 1.5.9

---
## 0.5.2-dev.2
* Support enabling compression configuration through `FTMobileFlutter.sdkConfig(compressIntakeRequests)`
* Support enabling Native LongTask detection and setting detection time range through `FTRUMManager().setConfig(enableNativeAppUIBlock, uiBlockDurationMS)`
* Support enabling Native ANR monitoring through `FTRUMManager().setConfig(enableTrackNativeAppANR)`
* Support enabling Android Java Crash, Android C/C++ Crash, iOS Crash monitoring through `FTRUMManager().setConfig(enableTrackNativeCrash)`
* Compatible with high version AGP 7.3+ namespace adaptation changes
* Compatible with Android ft-sdk 1.6.2, 1.6.3, 1.6.4 content, compatible with iOS 1.5.5, 1.5.6, 1.5.7 content

---
## 0.5.2-dev.1
* Support clearing unreported cache data through FTMobileFlutter.clearAllData()

---
## 0.5.1-pre.8
* Compatible with Android ft-sdk: 1.6.1
  * Fixed issue where custom startView called separately in RUM caused FTMetricsMTR monitoring thread not being recycled
  * Support adding dynamic attributes through FTSdk.appendGlobalContext(globalContext), FTSdk.appendRUMGlobalContext(globalContext),
    FTSdk.appendLogGlobalContext(globalContext)
  * Support clearing unreported cache data through FTSdk.clearAllData()
  * SDK setSyncSleepTime maximum limit extended to 5000 ms
* Compatible with iOS 1.5.4
  * Added global, log, RUM globalContext attribute dynamic setting methods
  * Added data clearing method, support deleting all data not yet uploaded to server
  * Adjusted maximum time interval supported by sync interval to 5000 milliseconds

---
## 0.5.1-pre.7
* Fixed issue where app foreground/background switching generated multiple View data
（ MaterialApp was reloaded, causing FTRouteObserver to have multiple instances, thus generating multiple monitoring data）

---
## 0.5.1-pre.6
* Fixed internal version marking error issue

---
## 0.5.1-pre.5
* Compatible with iOS 1.5.3
* Compatible with Android ft-sdk: 1.6.0, ft-plugin 1.3.3

---

## 0.5.1-pre.3
* Compatible with iOS 1.5.2, compatible with Xcode 16 

---
## 0.5.1-pre.2
* Compatible with Android ft-sdk:1.5.2, ft-native 1.1.1 ft-plugin 1.3.1
* Compatible with iOS 1.5.1

---
## 0.5.1-pre.1
* Optimized sleep/wake page monitoring setup method, no need to set FTLifeRecycleHandler
* Fixed issue where Android special scenarios after long-term use would occasionally frequently refresh session_id
* Android compatible with ft-sdk 1.5.1

---

## 0.5.1-dev.4
* Optimized sleep/wake page monitoring setup method, no need to set FTLifeRecycleHandler
* Fixed issue where Android special scenarios after long-term use would occasionally frequently refresh session_id
* Android compatible with ft-sdk 1.5.1.-alpha03

---
## 0.5.1-dev.3
* Extended FTDialogRouteFilterObserver to filter PopupRoute type pages
* Android compatible with ft-sdk 1.5.0, iOS compatible with 1.5.0

---

## 0.5.0-pre.1
* Same as 0.5.0-dev.2, 0.5.0-dev.3

---

## 0.5.0-dev.3
* Added FTDialogRouteFilterObserver to specifically filter DialogRoute type pages

---
## 0.5.0-dev.2
* FTRouteObserver added routeFilter, can filter pages that don't perform View tracking

---
## 0.4.6-pre.1
* Same as 0.4.6-dev.1

---
## 0.4.6-dev.1
* Android compatible with ft-sdk:1.4.3, ft-native:1.1.0, ft-plugin:1.3.0
* iOS compatible with 1.4.11

---
## 0.4.5-pre.4
* iOS compatible with 1.4.9-beta.5, iOS webview data time precision issue

---
## 0.4.5-pre.3
* iOS compatible with 1.4.9-beta.4, handling macOS compilation environment compatibility issues

---
## 0.4.5-pre.2
* iOS compatible with 1.4.9-beta.3

---
## 0.4.5-pre.1
* Android compatible with 1.4.1-beta01, iOS compatible with 1.4.9-beta.1
* Same as 0.4.5-dev.1

---
## 0.4.5-dev.1
* Added dataway upload method
* Error data added errorType data
* Fixed iOS enableUserResource off, getting trace header crash issue
* iOS compatible with 1.4.9-alpha.5, Android compatible with 1.4.1-alpha01

---
## 0.4.4-dev.1
* Android added maximum retry count configuration, added internal log handler object, handling addResource exception issues in certain cases
* Android compatible with ft-sdk:1.3.17-alpha05
* iOS 1.4.8-alpha.3

---
## 0.4.3-pre.1
* Android ft-sdk:1.3.17-beta01,ft-plugin:1.2.2-beta01
* iOS 1.4.7-beta.1

---
## 0.4.3-dev.5
* Android ft-sdk:1.3.16-alpha05

---
## 0.4.3-dev.4
* Android ft-sdk:1.3.16-beta01
* iOS compatible with 1.4.6-alpha.4

---
## 0.4.3-dev.3
* Android ft-sdk:1.3.16-alpha02
* iOS compatible with 1.4.6-alpha.1

---
## 0.4.3-dev.2
* webview feature update compatibility
* Android ft-sdk:1.3.16-alpha01,ft-plugin:1.2.2-alpha01
* iOS compatible with 1.4.5-alpha.1

---
## 0.4.2-pre.3
* Adjusted Java version compatibility

---
## 0.4.2-pre.2
* Removed dependency on http library

---
## 0.4.2-pre.1
* Added feature to print custom logs to console
* Same as 0.4.2-dev.1

---
## 0.4.2-dev.1
* iOS compatible with 1.4.4-beta.1
* Android compatible with ft-sdk:1.3.13-beta01

---
## 0.4.1-dev.1
* iOS compatible with 1.4.3-alpha.1
* Android compatible with ft-sdk:1.3.12-beta01, ft-native:1.0.0-beta01

---
## 0.4.0-dev.2
* SDK version display issue fix

---
## 0.4.0-dev.1
* Fixed iOS
* android ft-sdk:1.3.12-alpha01
* ios sdk 1.4.1-alpha.3

---
## 0.3.0-dev.1
* Added View Action Resource Log extension property
* Compatible with Android agent_1.3.10-beta02 
* Compatible with iOS 1.4.1-alpha.2

---
## 0.2.8-dev.9
* Compatible with Android 1.3.10-beta01

---
## 0.2.8-dev.8
* Compatible with Android 1.3.10-alpha01

---
## 0.2.8-dev.7
* Optimized ErrorMonitorType DeviceMetricsMonitorType configuration method

---
## 0.2.8-dev.6
* iOS compatible with 1.3.9-alpha.14

---
## 0.2.8-dev.5
* iOS compatible with 1.3.9-alpha.13
* Optimized route name display

---
## 0.2.8-dev.3
* trackEventFromExtension method adjustment

---
## 0.2.8-dev.2
* Compatible with iOS 1.3.9-alpha.11

---
## 0.2.8-dev.1
* Compatible with iOS 1.3.9-alpha.10
* Compatible with Android ft-sdk:1.3.8-beta03

---
## 0.2.7-dev.4
* Compatible with Android ft-sdk:1.3.8-beta02

---
## 0.2.7-dev.3
* Modified FTLifeRecycleHandler removeObserver error

---
## 0.2.7-dev.2
* Added RUM page auto-detection wake-up and sleep method

---
## 0.2.7-dev.1
* FTRouteObserver added from example to SDK

---
## 0.2.6-dev.1
* Added http autoTrack
* RUM view supplemented with the way to get view_name without setting route name

---
## 0.2.5-dev.4
* iOS action parameter adjustment

---
## 0.2.5-dev.3
* Optimized Android ID acquisition rule, can be dynamically controlled

---
## 0.2.5-dev.2
* Corrected iOS monitoring type parameter inefficiency issue

---
## 0.2.5-dev.1
* Added user information setting
* Added page monitoring metric reporting

---
## 0.2.4-dev.1
* Added longtask support

---
## 0.2.3-dev.10
* Upgraded Android ft-sdk:1.3.6-beta06

---
## 0.2.3-dev.8
* Upgraded Android ft-sdk:1.3.6-beta05

---
## 0.2.3-dev.7
* Upgraded Android ft-sdk:1.3.6-beta04

---
## 0.2.3-dev.6
* Upgraded Android ft-sdk:1.3.6-beta03
* Upgraded iOS 1.3.5-beta.4

---
## 0.2.3-dev.5
* Adjusted Android Native lib version ft-sdk:1.3.6-beta02

---
## 0.2.3-dev.4
* Adjusted Android Native lib version ft-sdk:1.3.6-beta02 

---
## 0.2.3-dev.3
* Adjusted Android Native lib version ft-native:1.0.0-alpha05
* Set iOS Native SDK 1.3.5-beta.3
---
## 0.2.3-dev.2
* Adjusted Android miniSDK to 21
* Upgraded iOS Native SDK 1.3.5-beta.2

---
## 0.2.3-dev.1
* iOS SDK version upgrade 1.3.5-beta.1
* Android SDK version upgrade 1.3.6-beta01

---
## 0.2.2-dev.2
* Adjusted Android SDK

---
## 0.2.2-dev.1
* Android Native Bug fix upgrade

---
## 0.2.1-dev.5
* Adjusted Android SDK

---
## 0.2.1-dev.4
* Adjusted Android SDK

---
## 0.2.1-dev.3
* Adjusted iOS SDK

---
## 0.2.1-dev.1
* Compatible with new Native SDK version

---
## 0.2.0-dev.5
* Fixed Android single trace data not triggering synchronization data issue

---
## 0.2.0-dev.4
* Upgraded iOS Android Native support library

---
## 0.2.0-dev.3
* Modified user binding method method name
* resource missing parameter added

---
## 0.2.0-dev.2
* Modified README LICENSE

---
## 0.2.0-dev.1
* Added Trace RUM Log call interface

---
## 0.1.0-dev.1
* Compatible with new rum SDK
* null safety

---
## 0.0.1-dev.5
* Updated Android iOS Dataflux SDK

---
## 0.0.1-dev.4
* Optimized geographical location acquisition method

---
## 0.0.1-dev.3
* Document format modification

---
## 0.0.1-dev.2
* Modified document

---
## 0.0.1-dev.1
* User custom event
* Flow chart reporting method
* Monitoring project association

