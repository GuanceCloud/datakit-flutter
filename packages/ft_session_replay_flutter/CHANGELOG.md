# ft_session_replay_flutter

## 0.1.0
* Added `FTSessionReplayManager().setConfig(FTSessionReplayConfig(...))` and `SessionReplayCapture` for Flutter Session Replay collection.
* Added Session Replay privacy configuration fields: `touchPrivacy`, `textAndInputPrivacy`, and `imagePrivacy`.
* Added `FTSessionReplayConfig(enableSwiftUI)` to enable iOS native SwiftUI Session Replay recording.
* Android bridge uses `ft-session-replay:0.1.6` with `ft-sdk:1.7.3` and `ft-native:1.1.3`.
* iOS bridge uses `FTMobileSDK` and `FTMobileSDK/FTSessionReplay` 1.6.5.
* SessionReplayCapture now registers with Session Replay when configuration is applied after the widget is already mounted.

---
## 0.1.0-pre.1
* Added `FTSessionReplayConfig(enableSwiftUI)` to enable iOS native SwiftUI Session Replay recording.
* Android bridge uses `ft-session-replay:0.1.6-beta01` with `ft-sdk:1.7.3`
  so Flutter external recorder mode and segment writing APIs are available.

---
## 0.1.0-dev.1
* Initial Session Replay package split from `ft_mobile_agent_flutter`.
* Android bridge uses `ft-session-replay:0.1.6-alpha02` with `ft-sdk:1.7.3`
  so Flutter external recorder mode and segment writing APIs are available.
* SessionReplayCapture now registers with Session Replay when configuration is
  applied after the widget is already mounted.
