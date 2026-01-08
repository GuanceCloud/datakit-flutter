#include "method_channel_handler.h"
#include "ft_sdk_adapter.h"
#include "data_converter.h"
#include "LoggerManager.h"
#include <thread>
#include <chrono>

namespace ft_mobile_agent_flutter {

// Method name constants
constexpr const char* METHOD_CONFIG = "ftConfig";
constexpr const char* METHOD_FLUSH_SYNC_DATA = "ftFlushSyncData";
constexpr const char* METHOD_BIND_USER = "ftBindUser";
constexpr const char* METHOD_UNBIND_USER = "ftUnBindUser";
constexpr const char* METHOD_RUM_CONFIG = "ftRumConfig";
constexpr const char* METHOD_RUM_START_ACTION = "ftRumStartAction";
constexpr const char* METHOD_RUM_ADD_ACTION = "ftRumAddAction";
constexpr const char* METHOD_RUM_START_VIEW = "ftRumStartView";
constexpr const char* METHOD_RUM_STOP_VIEW = "ftRumStopView";
constexpr const char* METHOD_RUM_ADD_ERROR = "ftRumAddError";
constexpr const char* METHOD_RUM_START_RESOURCE = "ftRumStartResource";
constexpr const char* METHOD_RUM_STOP_RESOURCE = "ftRumStopResource";
constexpr const char* METHOD_RUM_ADD_RESOURCE = "ftRumAddResource";
constexpr const char* METHOD_RUM_CREATE_VIEW = "ftRumCreateView";
constexpr const char* METHOD_LOG_CONFIG = "ftLogConfig";
constexpr const char* METHOD_LOGGING = "ftLogging";
constexpr const char* METHOD_TRACE_CONFIG = "ftTraceConfig";
constexpr const char* METHOD_GET_TRACE_HEADER = "ftTraceGetHeader";
constexpr const char* METHOD_APPEND_GLOBAL_CONTEXT = "ftAppendGlobalContext";
constexpr const char* METHOD_APPEND_RUM_GLOBAL_CONTEXT = "ftAppendRUMGlobalContext";
constexpr const char* METHOD_APPEND_LOG_GLOBAL_CONTEXT = "ftAppendLogGlobalContext";
constexpr const char* METHOD_CLEAR_ALL_DATA = "ftClearAllData";

void MethodChannelHandler::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    
    const std::string& method = method_call.method_name();
    com::ft::sdk::internal::LoggerManager::getInstance().logDebug("MethodChannelHandler: Received method call: {}", method);
    
    const flutter::EncodableValue* arguments = method_call.arguments();
    
    // Extract arguments as map if available
    flutter::EncodableMap args;
    if (arguments && std::holds_alternative<flutter::EncodableMap>(*arguments)) {
        args = std::get<flutter::EncodableMap>(*arguments);
    }
    
    try {
        if (method == METHOD_CONFIG) {
            HandleConfig(args, std::move(result));
        } else if (method == METHOD_FLUSH_SYNC_DATA) {
            HandleFlushSyncData(std::move(result));
        } else if (method == METHOD_BIND_USER) {
            HandleBindUser(args, std::move(result));
        } else if (method == METHOD_UNBIND_USER) {
            HandleUnbindUser(std::move(result));
        } else if (method == METHOD_RUM_CONFIG) {
            HandleRUMConfig(args, std::move(result));
        } else if (method == METHOD_RUM_START_ACTION) {
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("MethodChannelHandler: Routing to HandleRUMStartAction...");
            HandleRUMStartAction(args, std::move(result));
        } else if (method == METHOD_RUM_ADD_ACTION) {
            HandleRUMAddAction(args, std::move(result));
        } else if (method == METHOD_RUM_START_VIEW) {
            HandleRUMStartView(args, std::move(result));
        } else if (method == METHOD_RUM_STOP_VIEW) {
            HandleRUMStopView(args, std::move(result));
        } else if (method == METHOD_RUM_ADD_ERROR) {
            HandleRUMAddError(args, std::move(result));
        } else if (method == METHOD_RUM_START_RESOURCE) {
            HandleRUMStartResource(args, std::move(result));
        } else if (method == METHOD_RUM_STOP_RESOURCE) {
            HandleRUMStopResource(args, std::move(result));
        } else if (method == METHOD_RUM_ADD_RESOURCE) {
            HandleRUMAddResource(args, std::move(result));
        } else if (method == METHOD_RUM_CREATE_VIEW) {
            // CreateView is not supported in C++ SDK, just return success
            flutter::EncodableValue successValue(true);
            result->Success(successValue);
        } else if (method == METHOD_LOG_CONFIG) {
            HandleLogConfig(args, std::move(result));
        } else if (method == METHOD_LOGGING) {
            HandleLogging(args, std::move(result));
        } else if (method == METHOD_TRACE_CONFIG) {
            HandleTraceConfig(args, std::move(result));
        } else if (method == METHOD_GET_TRACE_HEADER) {
            HandleGetTraceHeader(args, std::move(result));
        } else if (method == METHOD_APPEND_GLOBAL_CONTEXT) {
            HandleAppendGlobalContext(args, std::move(result));
        } else if (method == METHOD_APPEND_RUM_GLOBAL_CONTEXT) {
            HandleAppendRUMGlobalContext(args, std::move(result));
        } else if (method == METHOD_APPEND_LOG_GLOBAL_CONTEXT) {
            HandleAppendLogGlobalContext(args, std::move(result));
        } else if (method == METHOD_CLEAR_ALL_DATA) {
            HandleClearAllData(std::move(result));
        } else {
            result->NotImplemented();
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleMethodCall: Exception: {}", e.what());
        try {
            result->Error("EXCEPTION", e.what());
        } catch (...) {
            // If Error() fails, ignore
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleMethodCall: Unknown exception");
        try {
            result->Error("EXCEPTION", "Unknown exception");
        } catch (...) {
            // If Error() fails, ignore
        }
    }
}

void MethodChannelHandler::HandleConfig(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleConfig: Converting config...");
        auto config = DataConverter::ConvertToSDKConfig(args);
        bool enableSdkLog = DataConverter::GetBool(args, "debug", false);
        std::string cliToken = DataConverter::GetString(args, "cliToken");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleConfig: Config converted, installing SDK...");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("ServerUrl: {}", config->getServerUrl());
        FTSDKAdapter::GetInstance().InstallSDK(*config, enableSdkLog, cliToken);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleConfig: SDK installed, calling Success()...");
        result->Success(flutter::EncodableValue(true));
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleConfig: Success() returned");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleConfig Error: {}", e.what());
        result->Error("CONFIG_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleFlushSyncData(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        FTSDKAdapter::GetInstance().FlushSyncData();
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("FLUSH_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleBindUser(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleBindUser: Converting user data...");
        auto userData = DataConverter::ConvertToUserData(args);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleBindUser: User data converted - userId={}, userName={}, userEmail={}", 
                  userData->getId(), userData->getName(), userData->getEmail());
        FTSDKAdapter::GetInstance().BindUserData(*userData);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleBindUser: BindUserData returned");
        
        // Create EncodableValue before calling Success to avoid potential issues
        flutter::EncodableValue successValue(true);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleBindUser: EncodableValue created, about to call Success()...");
        
        try {
            result->Success(successValue);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleBindUser: Success() returned");
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleBindUser: Exception in Success(): {}", e.what());
            throw;
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleBindUser: Unknown exception in Success()!");
            throw;
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleBindUser Error: {}", e.what());
        result->Error("BIND_USER_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleUnbindUser(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        FTSDKAdapter::GetInstance().UnbindUserData();
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("UNBIND_USER_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMConfig(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: Converting config...");
        auto config = DataConverter::ConvertToRUMConfig(args);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: Config converted, rumAppId={}", config->getRumAppId());
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: Calling InitRUMWithConfig...");
        {
            // Create a local copy to ensure config is valid during the call
            com::ft::sdk::FTRUMConfig configCopy = *config;
            FTSDKAdapter::GetInstance().InitRUMWithConfig(configCopy);
        }
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: InitRUMWithConfig returned, config object still valid");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: About to exit try block...");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: Checking result pointer...");
        if (!result) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMConfig: ERROR - result is null!");
            return;
        }
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: result pointer is valid");
        
        // Create EncodableValue before calling Success to avoid potential issues
        flutter::EncodableValue successValue(true);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: EncodableValue created, about to call Success()...");
        
        try {
            result->Success(successValue);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: Success() returned");
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMConfig: Exception in Success(): {}", e.what());
            throw;
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMConfig: Unknown exception in Success()!");
            throw;
        }
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMConfig: All done, exiting function");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMConfig Error: {}", e.what());
        result->Error("RUM_CONFIG_ERROR", e.what());
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMConfig: Unknown exception caught!");
        result->Error("RUM_CONFIG_ERROR", "Unknown exception");
    }
}

void MethodChannelHandler::HandleRUMStartAction(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartAction: Converting args...");
        std::string actionName = DataConverter::GetString(args, "actionName");
        std::string actionType = DataConverter::GetString(args, "actionType");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartAction: actionName={}, actionType={}", actionName, actionType);
        FTSDKAdapter::GetInstance().StartAction(actionName, actionType);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartAction: StartAction returned");
        
        // Create EncodableValue before calling Success to avoid potential issues
        flutter::EncodableValue successValue(true);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartAction: EncodableValue created, about to call Success()...");
        
        try {
            result->Success(successValue);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartAction: Success() returned");
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStartAction: Exception in Success(): {}", e.what());
            throw;
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStartAction: Unknown exception in Success()!");
            throw;
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStartAction Error: {}", e.what());
        result->Error("RUM_START_ACTION_ERROR", e.what());
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStartAction: Unknown exception!");
        result->Error("RUM_START_ACTION_ERROR", "Unknown exception");
    }
}

void MethodChannelHandler::HandleRUMAddAction(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMAddAction: Converting args...");
        std::string actionName = DataConverter::GetString(args, "actionName");
        std::string actionType = DataConverter::GetString(args, "actionType");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMAddAction: actionName={}, actionType={}", actionName, actionType);
        // Note: C++ SDK addAction might have different signature, check the actual API
        FTSDKAdapter::GetInstance().AddAction(actionName, actionType, 0, 0);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMAddAction: AddAction returned");
        
        // Create EncodableValue before calling Success to avoid potential issues
        flutter::EncodableValue successValue(true);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMAddAction: EncodableValue created, about to call Success()...");
        
        try {
            result->Success(successValue);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMAddAction: Success() returned");
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMAddAction: Exception in Success(): {}", e.what());
            throw;
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMAddAction: Unknown exception in Success()!");
            throw;
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMAddAction Error: {}", e.what());
        result->Error("RUM_ADD_ACTION_ERROR", e.what());
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMAddAction: Unknown exception!");
        result->Error("RUM_ADD_ACTION_ERROR", "Unknown exception");
    }
}

void MethodChannelHandler::HandleRUMStartView(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        std::string viewName = DataConverter::GetString(args, "viewName");
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartView: viewName={}", viewName);
        FTSDKAdapter::GetInstance().StartView(viewName);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStartView: Success");
        result->Success(flutter::EncodableValue(true));
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStartView Error: {}", e.what());
        result->Error("RUM_START_VIEW_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMStopView(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStopView called");
        FTSDKAdapter::GetInstance().StopView();
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleRUMStopView: Success");
        result->Success(flutter::EncodableValue(true));
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleRUMStopView Error: {}", e.what());
        result->Error("RUM_STOP_VIEW_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMAddError(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        std::string stack = DataConverter::GetString(args, "stack");
        std::string message = DataConverter::GetString(args, "message");
        std::string errorType = DataConverter::GetString(args, "errorType", "flutter_crash");
        int appState = DataConverter::GetInt(args, "appState", 2); // RUN
        
        FTSDKAdapter::GetInstance().AddError(
            stack, 
            message, 
            DataConverter::ConvertToRUMErrorType(errorType),
            DataConverter::ConvertToAppState(appState)
        );
        // Use explicit EncodableValue(true) to avoid nullptr being misinterpreted.
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("RUM_ADD_ERROR_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMStartResource(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        std::string key = DataConverter::GetString(args, "key");
        // Wrap StartResource in try/catch so errors do not affect subsequent calls.
        try {
            FTSDKAdapter::GetInstance().StartResource(key);
        } catch (...) {
            // Swallow all exceptions to avoid affecting HTTP requests.
        }
        // Use explicit EncodableValue(true) to avoid nullptr being misinterpreted.
        // Keep consistent with other handlers.
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("RUM_START_RESOURCE_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMStopResource(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        std::string key = DataConverter::GetString(args, "key");
        FTSDKAdapter::GetInstance().StopResource(key);
        // Use explicit EncodableValue(true) to avoid nullptr being misinterpreted.
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("RUM_STOP_RESOURCE_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleRUMAddResource(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        auto params = DataConverter::ConvertToResourceParams(args);
        std::string key = DataConverter::GetString(args, "key");
        com::ft::sdk::NetStatus netStatus;
        FTSDKAdapter::GetInstance().AddResource(key, *params, netStatus);
        // Use explicit EncodableValue(true) to avoid nullptr being misinterpreted.
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("RUM_ADD_RESOURCE_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleLogConfig(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleLogConfig: Converting config...");
        auto config = DataConverter::ConvertToLogConfig(args);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleLogConfig: Config converted, enableCustomLog={}", 
                  config->getEnableCustomLog() ? "true" : "false");
        FTSDKAdapter::GetInstance().InitLogWithConfig(*config);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleLogConfig: InitLogWithConfig returned");
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleLogConfig: Exception: {}", e.what());
        result->Error("LOG_CONFIG_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleLogging(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        std::string content = DataConverter::GetString(args, "content");
        int status = DataConverter::GetInt(args, "status", 0);
        try {
            FTSDKAdapter::GetInstance().AddLog(content, DataConverter::ConvertToLogLevel(status));
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleLogging: Error in AddLog: {}", e.what());
            // Continue to return success even if AddLog fails
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleLogging: Unknown error in AddLog");
            // Continue to return success even if AddLog fails
        }
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleLogging: Exception: {}", e.what());
        try {
            result->Error("LOGGING_ERROR", e.what());
        } catch (...) {
            // If Error() fails, ignore
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleLogging: Unknown exception");
        try {
            result->Error("LOGGING_ERROR", "Unknown exception");
        } catch (...) {
            // If Error() fails, ignore
        }
    }
}

void MethodChannelHandler::HandleTraceConfig(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        auto config = DataConverter::ConvertToTraceConfig(args);
        FTSDKAdapter::GetInstance().InitTraceWithConfig(*config);
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        result->Error("TRACE_CONFIG_ERROR", e.what());
    }
}

void MethodChannelHandler::HandleGetTraceHeader(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleGetTraceHeader: Starting...");
        
        std::string url = DataConverter::GetString(args, "url");
        std::string key = DataConverter::GetString(args, "key", "");
        
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleGetTraceHeader: url={}, key={}", 
                  url, key.empty() ? "(empty)" : key);
        
        std::map<std::string, std::string> headers;
        try {
        if (!key.empty()) {
            headers = FTSDKAdapter::GetInstance().GenerateTraceHeader(key, url);
        } else {
            headers = FTSDKAdapter::GetInstance().GenerateTraceHeader(url);
        }
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleGetTraceHeader: Generated {} headers", headers.size());
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Error in GenerateTraceHeader: {}", e.what());
            // If generation fails, return an empty map.
            headers = {};
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Unknown error in GenerateTraceHeader");
            headers = {};
        }
        
        try {
            flutter::EncodableValue resultValue = DataConverter::ConvertToEncodableValue(headers);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleGetTraceHeader: Converted to EncodableValue, calling Success()...");
            result->Success(resultValue);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("HandleGetTraceHeader: Success() returned");
        } catch (const std::exception& e) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Error in ConvertToEncodableValue: {}", e.what());
            // If conversion fails, return an empty map.
            result->Success(flutter::EncodableValue(flutter::EncodableMap()));
        } catch (...) {
            com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Unknown error in ConvertToEncodableValue");
            result->Success(flutter::EncodableValue(flutter::EncodableMap()));
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Exception: {}", e.what());
        try {
        result->Error("GET_TRACE_HEADER_ERROR", e.what());
        } catch (...) {
            // Ignore if even Error fails.
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleGetTraceHeader: Unknown exception");
        try {
            result->Error("GET_TRACE_HEADER_ERROR", "Unknown exception");
        } catch (...) {
            // Ignore if even Error fails.
        }
    }
}

void MethodChannelHandler::HandleAppendGlobalContext(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    // Note: C++ SDK might not have this method directly
    // This might need to be implemented differently
    flutter::EncodableValue successValue(true);
    result->Success(successValue);
}

void MethodChannelHandler::HandleAppendRUMGlobalContext(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        flutter::EncodableMap globalContextMap = DataConverter::GetMap(args, "globalContext");
        if (globalContextMap.empty()) {
            com::ft::sdk::internal::LoggerManager::getInstance().logWarn("HandleAppendRUMGlobalContext: globalContext is empty or missing");
            flutter::EncodableValue successValue(true);
            result->Success(successValue);
            return;
        }
        
        std::map<std::string, std::string> globalContext = DataConverter::ConvertToStringMap(globalContextMap);
        FTSDKAdapter::GetInstance().AppendRUMGlobalContext(globalContext);
        
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleAppendRUMGlobalContext: Exception: {}", e.what());
        try {
            result->Error("APPEND_RUM_GLOBAL_CONTEXT_ERROR", e.what());
        } catch (...) {
            // If Error() fails, ignore
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleAppendRUMGlobalContext: Unknown exception");
        try {
            result->Error("APPEND_RUM_GLOBAL_CONTEXT_ERROR", "Unknown exception");
        } catch (...) {
            // If Error() fails, ignore
        }
    }
}

void MethodChannelHandler::HandleAppendLogGlobalContext(
    const flutter::EncodableMap& args,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        flutter::EncodableMap globalContextMap = DataConverter::GetMap(args, "globalContext");
        if (globalContextMap.empty()) {
            com::ft::sdk::internal::LoggerManager::getInstance().logWarn("HandleAppendLogGlobalContext: globalContext is empty or missing");
            flutter::EncodableValue successValue(true);
            result->Success(successValue);
            return;
        }
        
        std::map<std::string, std::string> globalContext = DataConverter::ConvertToStringMap(globalContextMap);
        FTSDKAdapter::GetInstance().AppendLogGlobalContext(globalContext);
        
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleAppendLogGlobalContext: Exception: {}", e.what());
        try {
            result->Error("APPEND_LOG_GLOBAL_CONTEXT_ERROR", e.what());
        } catch (...) {
            // If Error() fails, ignore
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleAppendLogGlobalContext: Unknown exception");
        try {
            result->Error("APPEND_LOG_GLOBAL_CONTEXT_ERROR", "Unknown exception");
        } catch (...) {
            // If Error() fails, ignore
        }
    }
}

void MethodChannelHandler::HandleClearAllData(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    try {
        FTSDKAdapter::GetInstance().ClearAllData();
        flutter::EncodableValue successValue(true);
        result->Success(successValue);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleClearAllData: Exception: {}", e.what());
        try {
            result->Error("CLEAR_ALL_DATA_ERROR", e.what());
        } catch (...) {
            // If Error() fails, ignore
        }
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("HandleClearAllData: Unknown exception");
        try {
            result->Error("CLEAR_ALL_DATA_ERROR", "Unknown exception");
        } catch (...) {
            // If Error() fails, ignore
        }
    }
}

}  // namespace ft_mobile_agent_flutter

