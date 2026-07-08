
# GuanceCloud SDK Flutter


# Introduction
![](https://img.shields.io/badge/dynamic/json?label=pub.dev&color=blue&query=$.version&uri=https://static.guance.com/ft-sdk-package/badge/flutter/version.json) 
![](https://img.shields.io/badge/dynamic/json?label=legacy.github.tag&color=blue&query=$.version&uri=https://static.guance.com/ft-sdk-package/badge/flutter/legacy/version.json)
![](https://img.shields.io/badge/dynamic/json?label=platform&color=lightgrey&query=$.platform&uri=https://static.guance.com/ft-sdk-package/badge/flutter/info.json)

Based on **Guance iOS Android** SDK **Plugin**

# How to use

Please refer to the official documentation [click here](https://docs.guance.com/real-user-monitoring/flutter/app-access/)

# Flutter Web

`ft_mobile_agent_flutter` currently provides native bridge support for Android and iOS only. It does not provide a Flutter Web bridge.

If your app runs on Flutter Web, use the Guance Browser RUM SDK instead. In a Flutter Web project, load the Browser RUM SDK or your bundled initialization script from `web/index.html` before Flutter starts. This is a Browser RUM SDK integration, not a Flutter plugin integration.

For details, see the [Flutter Web notes](https://docs.guance.com/real-user-monitoring/flutter/app-access/#flutter-web) and the [Web RUM integration guide](https://docs.guance.com/real-user-monitoring/web/app-access/).
