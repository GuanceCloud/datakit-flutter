package com.cloudcare.ft.mobile.sdk.tracker.flutter;

import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_AUTO_SYNC;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_CLI_TOKEN;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_COMPRESS_INTAKE_REQUESTS;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_CUSTOM_SYNC_PAGE_SIZE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DATAKIT_URL;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DATAWAY_URL;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DATA_MODIFIER;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DB_CACHE_DISCARD;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DB_CACHE_LIMIT;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DEBUG;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DETECT_FREQUENCY;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_DEVICE_METRICS_MONITOR_TYPE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_APP_UI_BLOCK;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_CUSTOM_LOG;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_DATA_INTEGER_COMPATIBLE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_LIMIT_WITH_DB_SIZE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_LINK_RUM_DATA;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_NATIVE_AUTO_TRACE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_TRACK_NATIVE_APP_ANR;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_TRACK_NATIVE_CRASH;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_USER_ACTION;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_USER_RESOURCE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_USER_VIEW;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENABLE_USER_VIEW_IN_FRAGMENT;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ENV_TYPE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_ERROR_MONITOR_TYPE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_GLOBAL_CONTEXT;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_LINE_DATA_MODIFIER;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_LOG_CACHE_DISCARD;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_LOG_CACHE_LIMIT_COUNT;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_LOG_TYPE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_NATIVE_UI_BLOCK_DURATION_MS;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_PRINT_CUSTOM_LOG_TO_CONSOLE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_RUM_APP_ID;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_RUM_CACHE_DISCARD;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_RUM_CACHE_LIMIT_COUNT;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_SAMPLE_RATE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_SERVICE_NAME;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_SESSION_ON_ERROR_SAMPLE_RATE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_SYNC_PAGE_SIZE;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_SYNC_SLEEP_TIME;
import static com.cloudcare.ft.mobile.sdk.tracker.flutter.FTMobileAgentFlutter.KEY_TRACE_TYPE;

import com.ft.sdk.FTLoggerConfig;
import com.ft.sdk.FTRUMConfig;
import com.ft.sdk.FTSDKConfig;
import com.ft.sdk.FTTraceConfig;
import com.ft.sdk.SyncPageSize;
import com.ft.sdk.garble.bean.Status;
import com.ft.sdk.garble.utils.Constants;
import com.ft.sdk.garble.utils.LogUtils;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;

public class FTConfigCheck {
    private static final String LOG_TAG = Constants.LOG_TAG_PREFIX + "FTConfigCheck";

    /**
     * @param args
     * @param sdkConfig
     */
    public void validateSDKConfig(Map<String, Object> args, FTSDKConfig sdkConfig) {
        Map<String, Object> configMap = new HashMap<String, Object>() {{
            put(KEY_DATAKIT_URL, sdkConfig.getDatakitUrl());
            put(KEY_DATAWAY_URL, sdkConfig.getDatawayUrl());
            put(KEY_CLI_TOKEN, sdkConfig.getClientToken());
            put(KEY_ENV_TYPE, sdkConfig.getEnv());
            put(KEY_DEBUG, sdkConfig.isDebug());
            put(KEY_SERVICE_NAME, sdkConfig.getServiceName());
            put(KEY_AUTO_SYNC, sdkConfig.isAutoSync());
            put(KEY_SYNC_PAGE_SIZE, sdkConfig.getPageSize());
            put(KEY_CUSTOM_SYNC_PAGE_SIZE, sdkConfig.getPageSize());
            put(KEY_SYNC_SLEEP_TIME, sdkConfig.getSyncSleepTime());
            put(KEY_COMPRESS_INTAKE_REQUESTS, sdkConfig.isCompressIntakeRequests());
            put(KEY_ENABLE_DATA_INTEGER_COMPATIBLE, sdkConfig.isEnableDataIntegerCompatible());
            put(KEY_GLOBAL_CONTEXT, sdkConfig.getGlobalContext());
            put(KEY_ENABLE_LIMIT_WITH_DB_SIZE, sdkConfig.isLimitWithDbSize());
            put(KEY_DB_CACHE_LIMIT, sdkConfig.getDbCacheLimit());
            put(KEY_DB_CACHE_DISCARD, sdkConfig.getDbCacheDiscard());
            put(KEY_LINE_DATA_MODIFIER, sdkConfig.getLineDataModifier());
            put(KEY_DATA_MODIFIER, sdkConfig.getDataModifier());
        }};

        for (Map.Entry<String, Object> entry : args.entrySet()) {
            if (entry.getValue() == null) continue;

            String keyStr = entry.getKey();
            Object value = entry.getValue();

            if (KEY_SYNC_PAGE_SIZE.equals(keyStr)) {
                int syncPageSize = (int) value;
                boolean match = SyncPageSize.values()[syncPageSize].getValue() == sdkConfig.getPageSize();
                if (!match) {
                    logNotMatch(keyStr, value, sdkConfig.getDataModifier());
                }
                continue;
            }

            if (KEY_GLOBAL_CONTEXT.equals(keyStr)) {
                globalContextCheck((Map<?, ?>) value, keyStr, sdkConfig.getGlobalContext());
                continue;
            }

            if (KEY_DATA_MODIFIER.equals(keyStr)) {
                boolean match = value != null && sdkConfig.getDataModifier() != null;
                if (!match) {
                    logNotMatch(keyStr, value, sdkConfig.getDataModifier());
                }
                continue;
            }

            if (KEY_LINE_DATA_MODIFIER.equals(keyStr)) {
                boolean match = value != null && sdkConfig.getLineDataModifier() != null;
                if (!match) {
                    logNotMatch(keyStr, value, sdkConfig.getLineDataModifier());
                }
                continue;
            }

            normalItemCheck(keyStr, value, configMap);
        }
    }

    /**
     * @param args
     * @param sdkConfig
     */
    public void validateRUMConfig(Map<String, Object> args, FTRUMConfig sdkConfig) {
        Map<String, Object> configMap = new HashMap<String, Object>() {{
            put(KEY_RUM_APP_ID, sdkConfig.getRumAppId());
            put(KEY_SAMPLE_RATE, sdkConfig.getSamplingRate());
            put(KEY_SESSION_ON_ERROR_SAMPLE_RATE, sdkConfig.getSessionErrorSampleRate());
            put(KEY_ENABLE_USER_ACTION, sdkConfig.isEnableTraceUserAction());
            put(KEY_ENABLE_USER_VIEW, sdkConfig.isEnableTraceUserView());
            put(KEY_ENABLE_USER_VIEW_IN_FRAGMENT, sdkConfig.isEnableTraceUserViewInFragment());
            put(KEY_ENABLE_USER_RESOURCE, sdkConfig.isEnableTraceUserResource());
            put(KEY_ENABLE_APP_UI_BLOCK, sdkConfig.isEnableTrackAppUIBlock());
            put(KEY_NATIVE_UI_BLOCK_DURATION_MS, sdkConfig.getBlockDurationMS());
            put(KEY_ENABLE_TRACK_NATIVE_APP_ANR, sdkConfig.isEnableTrackAppANR());
            put(KEY_ENABLE_TRACK_NATIVE_CRASH, sdkConfig.isEnableTrackAppCrash());
            put(KEY_ERROR_MONITOR_TYPE, sdkConfig.getExtraMonitorTypeWithError());
            put(KEY_DEVICE_METRICS_MONITOR_TYPE, sdkConfig.getDeviceMetricsMonitorType());
            put(KEY_DETECT_FREQUENCY, sdkConfig.getDeviceMetricsDetectFrequency());
            put(KEY_GLOBAL_CONTEXT, sdkConfig.getGlobalContext());
            put(KEY_RUM_CACHE_LIMIT_COUNT, sdkConfig.getRumCacheLimitCount());
            put(KEY_RUM_CACHE_DISCARD, sdkConfig.getRumCacheDiscardStrategy());
        }};

        for (Map.Entry<String, Object> entry : args.entrySet()) {
            if (entry.getValue() == null) continue;
            String keyStr = entry.getKey();
            Object value = entry.getValue();

            if (KEY_GLOBAL_CONTEXT.equals(keyStr)) {
                globalContextCheck((Map<?, ?>) value, keyStr, sdkConfig.getGlobalContext());
                continue;
            }

            if (KEY_DEVICE_METRICS_MONITOR_TYPE.equals(keyStr)) {
                boolean match = ((Number) value).intValue() == sdkConfig.getDeviceMetricsMonitorType();
                if (!match) logNotMatch(keyStr, value, sdkConfig.getDeviceMetricsMonitorType());
                continue;
            }

            if (KEY_ERROR_MONITOR_TYPE.equals(keyStr)) {
                boolean match = ((Number) value).intValue() == sdkConfig.getExtraMonitorTypeWithError();
                if (!match) logNotMatch(keyStr, value, sdkConfig.getExtraMonitorTypeWithError());
                continue;
            }

            normalItemCheck(keyStr, value, configMap);
        }
    }

    /**
     * @param args
     * @param sdkConfig
     */
    public void validateLogConfig(Map<String, Object> args, FTLoggerConfig sdkConfig) {
        Map<String, Object> configMap = new HashMap<String, Object>() {{
            put(KEY_SAMPLE_RATE, sdkConfig.getSamplingRate());
            put(KEY_ENABLE_LINK_RUM_DATA, sdkConfig.isEnableLinkRumData());
            put(KEY_ENABLE_CUSTOM_LOG, sdkConfig.isEnableCustomLog());
            put(KEY_LOG_CACHE_DISCARD, sdkConfig.getLogCacheDiscardStrategy());
            put(KEY_LOG_CACHE_LIMIT_COUNT, sdkConfig.getLogCacheLimitCount());
            put(KEY_PRINT_CUSTOM_LOG_TO_CONSOLE, sdkConfig.isPrintCustomLogToConsole());
            put(KEY_GLOBAL_CONTEXT, sdkConfig.getGlobalContext());
        }};

        for (Map.Entry<String, Object> entry : args.entrySet()) {
            if (entry.getValue() == null) continue;

            String keyStr = entry.getKey();
            Object value = entry.getValue();

            if (KEY_LOG_TYPE.equals(keyStr) && value instanceof List) {
                List<?> list = (List<?>) value;
                for (Object o : list) {
                    if (o instanceof Integer) {
                        int level = ((Integer) o);
                        Status[] values = Status.values();
                        Status status = null;
                        for (Status s : values) {
                            if (level > Status.INFO.ordinal()) {
                                if (level + 1 == s.ordinal()) {
                                    status = s;
                                    break;
                                }
                            } else if (level == s.ordinal()) {
                                status = s;
                                break;
                            }
                        }
                        if (status != null && !sdkConfig.checkLogLevel(status.name())) {
                            logNotMatch(keyStr, value, status.name());
                        }
                    }
                }
                continue;
            }

            if (KEY_GLOBAL_CONTEXT.equals(keyStr)) {
                globalContextCheck((Map<?, ?>) value, keyStr, sdkConfig.getGlobalContext());
                continue;
            }

            normalItemCheck(keyStr, value, configMap);
        }
    }

    /**
     * @param args
     * @param sdkConfig
     */
    public void validateTraceConfig(Map<String, Object> args, FTTraceConfig sdkConfig) {
        Map<String, Object> configMap = new HashMap<String, Object>() {{
            put(KEY_SAMPLE_RATE, sdkConfig.getSamplingRate());
            put(KEY_TRACE_TYPE, sdkConfig.getTraceType().ordinal());
            put(KEY_ENABLE_LINK_RUM_DATA, sdkConfig.isEnableLinkRUMData());
            put(KEY_ENABLE_NATIVE_AUTO_TRACE, sdkConfig.isEnableAutoTrace());
        }};

        for (Map.Entry<String, Object> entry : args.entrySet()) {
            if (entry.getValue() == null) continue;

            String keyStr = entry.getKey();
            Object value = entry.getValue();

            normalItemCheck(keyStr, value, configMap);
        }
    }

    /**
     * @param flutterMap
     * @param keyStr
     * @param realGlobalContext
     */
    private void globalContextCheck(Map<?, ?> flutterMap, String keyStr, Map<?, ?> realGlobalContext) {
        if (flutterMap != null) {
            for (Map.Entry<?, ?> entry : flutterMap.entrySet()) {
                boolean match = Objects.equals(realGlobalContext.get(entry.getKey()), entry.getValue());
                if (!match) {
                    LogUtils.e(LOG_TAG, "key:" + keyStr + ", value:" + entry.getValue() +
                            ", config:" + realGlobalContext + ", not match");
                }
            }
        }
    }

    /**
     * @param keyStr
     * @param value
     * @param configMap
     */
    private void normalItemCheck(String keyStr, Object value, Map<String, Object> configMap) {
        if (configMap.containsKey(keyStr)) {
            Object configValue = configMap.get(keyStr);
            if (!Objects.equals(value, configValue)) {
                logNotMatch(keyStr, value, configValue);
            }
        }
    }

    /**
     * @param key
     * @param flutterValue
     * @param realValue
     */
    private void logNotMatch(String key, Object flutterValue, Object realValue) {
        LogUtils.e(LOG_TAG, "key:" + key + ", value:" + flutterValue + ", config:" + realValue + ", not match");
    }

    /**
     * @param call
     * @return
     */
    public Map<String, Object> flutterArgsConvert(MethodCall call) {
        String method = call.method;
        Object argsObj = call.arguments;
        if (!(argsObj instanceof Map)) {
            LogUtils.e(LOG_TAG, method + ": call invoke failed");
            return Collections.emptyMap();
        }

        Map<String, Object> args = (Map<String, Object>) argsObj;
        checkArguments(method, args);
        return args;
    }

    /**
     * @param method
     * @param args
     */
    private void checkArguments(String method, Map<String, Object> args) {
        for (Map.Entry<String, Object> entry : args.entrySet()) {
            if (entry.getValue() == null) {
                LogUtils.d("FTConfigCheck", method + "\nnot set:" + entry.getKey());
            }
        }
    }
}