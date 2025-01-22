package com.ft.sdk

class InnerClassProxy {

    companion object {
        fun addPkgInfo(config: FTSDKConfig, key: String, value: String) {
            config.addPkgInfo(key, value)
        }
    }
}