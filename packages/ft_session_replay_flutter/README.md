# ft_session_replay_flutter

![](https://img.shields.io/badge/dynamic/json?label=pub.dev&color=orange&query=$.version&uri=https://static.guance.com/ft-sdk-package/badge/flutter/replay/version.json)

Flutter Session Replay plugin for Guance mobile SDK.

Use this package together with `ft_mobile_agent_flutter`. Initialize the base SDK
and RUM before enabling Session Replay.

Android depends on native `ft-session-replay:0.1.6-alpha02` and `ft-sdk:1.7.3`
or newer compatible versions because Flutter capture uses the native external
recorder bridge.
