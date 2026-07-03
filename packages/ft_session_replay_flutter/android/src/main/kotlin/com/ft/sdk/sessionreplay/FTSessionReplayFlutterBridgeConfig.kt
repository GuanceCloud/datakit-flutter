package com.ft.sdk.sessionreplay

internal object FTSessionReplayFlutterBridgeConfig {
    fun markExternalRecorderMode(config: FTSessionReplayConfig): Boolean {
        return try {
            val method = config.javaClass.getDeclaredMethod(
                "setExternalRecorderMode",
                java.lang.Boolean.TYPE
            )
            method.isAccessible = true
            method.invoke(config, true)
            true
        } catch (e: Throwable) {
            false
        }
    }
}
