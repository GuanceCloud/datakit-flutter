#include "data_converter.h"
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4251)
#endif
#include "FTSDKConfig.h"
#include "FTSDKDataContracts.h"
#ifdef _MSC_VER
#pragma warning(pop)
#endif
#include <algorithm>
#include <sstream>
#include <iostream>

namespace ft_mobile_agent_flutter {

// Helper method implementations
std::string DataConverter::GetString(const flutter::EncodableMap& map, const std::string& key, const std::string& defaultValue) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end() && std::holds_alternative<std::string>(it->second)) {
        return std::get<std::string>(it->second);
    }
    return defaultValue;
}

bool DataConverter::GetBool(const flutter::EncodableMap& map, const std::string& key, bool defaultValue) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end() && std::holds_alternative<bool>(it->second)) {
        return std::get<bool>(it->second);
    }
    return defaultValue;
}

double DataConverter::GetDouble(const flutter::EncodableMap& map, const std::string& key, double defaultValue) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end()) {
        if (std::holds_alternative<double>(it->second)) {
            return std::get<double>(it->second);
        } else if (std::holds_alternative<int32_t>(it->second)) {
            return static_cast<double>(std::get<int32_t>(it->second));
        } else if (std::holds_alternative<int64_t>(it->second)) {
            return static_cast<double>(std::get<int64_t>(it->second));
        }
    }
    return defaultValue;
}

int DataConverter::GetInt(const flutter::EncodableMap& map, const std::string& key, int defaultValue) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end()) {
        if (std::holds_alternative<int32_t>(it->second)) {
            return std::get<int32_t>(it->second);
        } else if (std::holds_alternative<int64_t>(it->second)) {
            return static_cast<int>(std::get<int64_t>(it->second));
        }
    }
    return defaultValue;
}

flutter::EncodableMap DataConverter::GetMap(const flutter::EncodableMap& map, const std::string& key) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end() && std::holds_alternative<flutter::EncodableMap>(it->second)) {
        return std::get<flutter::EncodableMap>(it->second);
    }
    return flutter::EncodableMap();
}

flutter::EncodableList DataConverter::GetList(const flutter::EncodableMap& map, const std::string& key) {
    auto it = map.find(flutter::EncodableValue(key));
    if (it != map.end() && std::holds_alternative<flutter::EncodableList>(it->second)) {
        return std::get<flutter::EncodableList>(it->second);
    }
    return flutter::EncodableList();
}

std::map<std::string, std::string> DataConverter::ConvertToStringMap(const flutter::EncodableMap& map) {
    std::map<std::string, std::string> result;
    for (const auto& pair : map) {
        std::string key;
        if (std::holds_alternative<std::string>(pair.first)) {
            key = std::get<std::string>(pair.first);
        } else {
            continue; // Skip non-string keys
        }
        
        std::string value;
        if (std::holds_alternative<std::string>(pair.second)) {
            value = std::get<std::string>(pair.second);
        } else if (std::holds_alternative<int32_t>(pair.second)) {
            value = std::to_string(std::get<int32_t>(pair.second));
        } else if (std::holds_alternative<int64_t>(pair.second)) {
            value = std::to_string(std::get<int64_t>(pair.second));
        } else if (std::holds_alternative<double>(pair.second)) {
            value = std::to_string(std::get<double>(pair.second));
        } else if (std::holds_alternative<bool>(pair.second)) {
            value = std::get<bool>(pair.second) ? "true" : "false";
        } else {
            continue; // Skip unsupported types
        }
        
        result[key] = value;
    }
    return result;
}

// Enum conversions
com::ft::sdk::AppState DataConverter::ConvertToAppState(int value) {
    if (value >= 0 && value <= 2) {
        return static_cast<com::ft::sdk::AppState>(value);
    }
    return com::ft::sdk::AppState::UNKNOWN;
}

com::ft::sdk::LogLevel DataConverter::ConvertToLogLevel(int value) {
    if (value >= 0 && value <= 4) {
        return static_cast<com::ft::sdk::LogLevel>(value);
    }
    return com::ft::sdk::LogLevel::INFO;
}

com::ft::sdk::TraceType DataConverter::ConvertToTraceType(int value) {
    if (value >= 0 && value <= 5) {
        return static_cast<com::ft::sdk::TraceType>(value);
    }
    return com::ft::sdk::TraceType::DDTRACE;
}

com::ft::sdk::RUMErrorType DataConverter::ConvertToRUMErrorType(const std::string& errorType) {
    if (errorType == "native_crash") return com::ft::sdk::RUMErrorType::NATIVE_CRASH;
    if (errorType == "java_crash") return com::ft::sdk::RUMErrorType::JAVA_CRASH;
    if (errorType == "flutter_crash") return com::ft::sdk::RUMErrorType::FLUTTER_CRASH;
    if (errorType == "network_error") return com::ft::sdk::RUMErrorType::NETWORK_ERROR;
    return com::ft::sdk::RUMErrorType::FLUTTER_CRASH; // default
}

com::ft::sdk::EnvType DataConverter::ConvertToEnvType(const std::string& env) {
    if (env == "prod" || env == "PROD") return com::ft::sdk::EnvType::PROD;
    if (env == "gray" || env == "GRAY") return com::ft::sdk::EnvType::GRAY;
    if (env == "pre" || env == "PRE") return com::ft::sdk::EnvType::PRE;
    if (env == "common" || env == "COMMON") return com::ft::sdk::EnvType::COMMON;
    if (env == "local" || env == "LOCAL") return com::ft::sdk::EnvType::LOCAL;
    return com::ft::sdk::EnvType::PROD; // default
}

// Convert C++ types to Flutter EncodableValue
flutter::EncodableValue DataConverter::ConvertToEncodableValue(const std::map<std::string, std::string>& map) {
    flutter::EncodableMap result;
    for (const auto& pair : map) {
        result[flutter::EncodableValue(pair.first)] = flutter::EncodableValue(pair.second);
    }
    return flutter::EncodableValue(result);
}

flutter::EncodableValue DataConverter::ConvertToEncodableValue(const std::string& str) {
    return flutter::EncodableValue(str);
}

flutter::EncodableValue DataConverter::ConvertToEncodableValue(int value) {
    return flutter::EncodableValue(value);
}

flutter::EncodableValue DataConverter::ConvertToEncodableValue(bool value) {
    return flutter::EncodableValue(value);
}

// SDK Config conversion
std::unique_ptr<com::ft::sdk::FTSDKConfig> DataConverter::ConvertToSDKConfig(const flutter::EncodableMap& args) {
    auto config = std::make_unique<com::ft::sdk::FTSDKConfig>();
    
    // Get datakitUrl or datawayUrl
    std::string datakitUrl = GetString(args, "datakitUrl");
    std::string datawayUrl = GetString(args, "datawayUrl");
    std::string cliToken = GetString(args, "cliToken");
    
    if (!datakitUrl.empty()) {
        config->setServerUrl(datakitUrl);
    } else if (!datawayUrl.empty()) {
        config->setServerUrl(datawayUrl);
    }

    if (!cliToken.empty()) {
        config->setClientToken(cliToken);
    }
    
    // Service name
    std::string serviceName = GetString(args, "serviceName");
    if (!serviceName.empty()) {
        config->setServiceName(serviceName);
    }
    
    // Environment
    std::string env = GetString(args, "env");
    if (!env.empty()) {
        config->setEnv(ConvertToEnvType(env));
    }
    
    // Global context
    flutter::EncodableMap globalContext = GetMap(args, "globalContext");
    for (const auto& pair : globalContext) {
        if (std::holds_alternative<std::string>(pair.first) && 
            std::holds_alternative<std::string>(pair.second)) {
            config->addGlobalContext(
                std::get<std::string>(pair.first),
                std::get<std::string>(pair.second)
            );
        }
    }
    
    return config;
}

// RUM Config conversion
std::unique_ptr<com::ft::sdk::FTRUMConfig> DataConverter::ConvertToRUMConfig(const flutter::EncodableMap& args) {
    auto config = std::make_unique<com::ft::sdk::FTRUMConfig>();
    
    // RUM App ID (required)
    std::string rumAppId = GetString(args, "rumAppId");
    if (!rumAppId.empty()) {
        config->setRumAppId(rumAppId);
    }
    
    // Sample rate
    double sampleRate = GetDouble(args, "sampleRate", 1.0);
    config->setSamplingRate(static_cast<float>(sampleRate));
    
    // Session on error sample rate
    double sessionOnErrorSampleRate = GetDouble(args, "sessionOnErrorSampleRate", 0.0);
    // Note: C++ SDK might not have this, check the actual API
    
    // Global context
    flutter::EncodableMap globalContext = GetMap(args, "globalContext");
    for (const auto& pair : globalContext) {
        if (std::holds_alternative<std::string>(pair.first) && 
            std::holds_alternative<std::string>(pair.second)) {
            config->addGlobalContext(
                std::get<std::string>(pair.first),
                std::get<std::string>(pair.second)
            );
        }
    }
    
    return config;
}

// Log Config conversion
std::unique_ptr<com::ft::sdk::FTLogConfig> DataConverter::ConvertToLogConfig(const flutter::EncodableMap& args) {
    auto config = std::make_unique<com::ft::sdk::FTLogConfig>();
    
    // Sample rate
    double sampleRate = GetDouble(args, "sampleRate", 1.0);
    config->setSamplingRate(static_cast<float>(sampleRate));
    
    // Enable custom log
    bool enableCustomLog = GetBool(args, "enableCustomLog", false);
    config->setEnableCustomLog(enableCustomLog);
    
    // Enable link RUM data
    bool enableLinkRumData = GetBool(args, "enableLinkRumData", false);
    config->setEnableLinkRumData(enableLinkRumData);
    
    // Log level filters
    flutter::EncodableList logTypeArr = GetList(args, "logType");
    if (!logTypeArr.empty()) {
        std::vector<com::ft::sdk::LogLevel> logLevels;
        for (const auto& item : logTypeArr) {
            if (std::holds_alternative<int32_t>(item)) {
                int level = std::get<int32_t>(item);
                logLevels.push_back(ConvertToLogLevel(level));
            }
        }
        config->setLogLevelFilters(logLevels);
    }
    
    // Global context
    flutter::EncodableMap globalContext = GetMap(args, "globalContext");
    for (const auto& pair : globalContext) {
        if (std::holds_alternative<std::string>(pair.first) && 
            std::holds_alternative<std::string>(pair.second)) {
            config->addGlobalContext(
                std::get<std::string>(pair.first),
                std::get<std::string>(pair.second)
            );
        }
    }
    
    return config;
}

// Trace Config conversion
std::unique_ptr<com::ft::sdk::FTTraceConfig> DataConverter::ConvertToTraceConfig(const flutter::EncodableMap& args) {
    auto config = std::make_unique<com::ft::sdk::FTTraceConfig>();
    
    // Sample rate
    double sampleRate = GetDouble(args, "sampleRate", 1.0);
    config->setSamplingRate(static_cast<float>(sampleRate));
    
    // Trace type
    int traceType = GetInt(args, "traceType", 0);
    config->setTraceType(ConvertToTraceType(traceType));
    
    // Enable link RUM data
    bool enableLinkRUMData = GetBool(args, "enableLinkRUMData", false);
    config->setEnableLinkRUMData(enableLinkRUMData);
    
    return config;
}

// User Data conversion
std::unique_ptr<com::ft::sdk::UserData> DataConverter::ConvertToUserData(const flutter::EncodableMap& args) {
    auto userData = std::make_unique<com::ft::sdk::UserData>();
    
    std::string userId = GetString(args, "userId");
    std::string userName = GetString(args, "userName");
    std::string userEmail = GetString(args, "userEmail");
    
    std::cout << "[FT SDK] ConvertToUserData: Received - userId=" << userId 
              << ", userName=" << userName 
              << ", userEmail=" << userEmail << std::endl;
    
    if (!userId.empty() || !userName.empty() || !userEmail.empty()) {
        userData->init(userName, userId, userEmail);
        std::cout << "[FT SDK] ConvertToUserData: Initialized user data" << std::endl;
    } else {
        std::cout << "[FT SDK] ConvertToUserData: Warning - all user fields are empty!" << std::endl;
    }
    
    // User extensions
    flutter::EncodableMap userExt = GetMap(args, "userExt");
    for (const auto& pair : userExt) {
        if (std::holds_alternative<std::string>(pair.first) && 
            std::holds_alternative<std::string>(pair.second)) {
            userData->addCustomizeItem(
                std::get<std::string>(pair.first),
                std::get<std::string>(pair.second)
            );
        }
    }
    
    return userData;
}

// Helper function to serialize headers map to string
std::string SerializeHeaders(const flutter::EncodableMap& headers) {
    std::ostringstream oss;
    bool first = true;
    for (const auto& pair : headers) {
        if (!first) oss << "\n";
        if (std::holds_alternative<std::string>(pair.first)) {
            std::string key = std::get<std::string>(pair.first);
            if (std::holds_alternative<std::string>(pair.second)) {
                oss << key << ": " << std::get<std::string>(pair.second);
            } else if (std::holds_alternative<flutter::EncodableList>(pair.second)) {
                // Handle list of strings (multiple values for same header)
                auto list = std::get<flutter::EncodableList>(pair.second);
                bool firstValue = true;
                for (const auto& item : list) {
                    if (!firstValue) oss << ", ";
                    if (std::holds_alternative<std::string>(item)) {
                        oss << std::get<std::string>(item);
                    }
                    firstValue = false;
                }
            }
        }
        first = false;
    }
    return oss.str();
}

// Resource Params conversion
std::unique_ptr<com::ft::sdk::ResourceParams> DataConverter::ConvertToResourceParams(const flutter::EncodableMap& args) {
    auto params = std::make_unique<com::ft::sdk::ResourceParams>();
    
    params->url = GetString(args, "url");
    params->resourceMethod = GetString(args, "resourceMethod");
    params->resourceStatus = GetInt(args, "resourceStatus", -1);
    params->responseBody = GetString(args, "responseBody");
    
    // Request headers - serialize to string
    flutter::EncodableMap requestHeader = GetMap(args, "requestHeader");
    params->requestHeader = SerializeHeaders(requestHeader);
    
    // Response headers - serialize to string
    flutter::EncodableMap responseHeader = GetMap(args, "responseHeader");
    params->responseHeader = SerializeHeaders(responseHeader);
    
    // Extract content-type and connection from response headers
    if (!responseHeader.empty()) {
        auto contentTypeIt = responseHeader.find(flutter::EncodableValue("content-type"));
        if (contentTypeIt != responseHeader.end()) {
            if (std::holds_alternative<std::string>(contentTypeIt->second)) {
                params->responseContentType = std::get<std::string>(contentTypeIt->second);
            } else if (std::holds_alternative<flutter::EncodableList>(contentTypeIt->second)) {
                auto list = std::get<flutter::EncodableList>(contentTypeIt->second);
                if (!list.empty() && std::holds_alternative<std::string>(list[0])) {
                    params->responseContentType = std::get<std::string>(list[0]);
                }
            }
        }
        
        auto connectionIt = responseHeader.find(flutter::EncodableValue("connection"));
        if (connectionIt != responseHeader.end()) {
            if (std::holds_alternative<std::string>(connectionIt->second)) {
                params->responseConnection = std::get<std::string>(connectionIt->second);
            }
        }
    }
    
    return params;
}

}  // namespace ft_mobile_agent_flutter

