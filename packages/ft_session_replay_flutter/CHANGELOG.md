# ft_session_replay_flutter

## 0.1.0-pre.1
* same as 0.1.0-dev.1

---
## 0.1.0-dev.1
* Initial Session Replay package split from `ft_mobile_agent_flutter`.
* Android bridge uses `ft-session-replay:0.1.6-alpha02` with `ft-sdk:1.7.3`
  so Flutter external recorder mode and segment writing APIs are available.
* SessionReplayCapture now registers with Session Replay when configuration is
  applied after the widget is already mounted.
