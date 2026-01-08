#include "ft_sdk_adapter.h"
#include "FTSDKFactory.h"
#include "LineDBManager.h"
#include "FTSDKConfigManager.h"
#include "FTSDKConstants.h"
#include "Utils.h"
#include "LoggerManager.h"
#include <nlohmann/json.hpp>
#include <set>

namespace ft_mobile_agent_flutter {

namespace {
std::string MaskToken(const std::string& token) {
    if (token.size() <= 8) {
        return "***";
    }
    return token.substr(0, 4) + "..." + token.substr(token.size() - 4);
}
} // namespace

FTSDKAdapter& FTSDKAdapter::GetInstance() {
    static FTSDKAdapter instance;
    return instance;
}

void FTSDKAdapter::InstallSDK(com::ft::sdk::FTSDKConfig& config, bool enableSdkLog, const std::string& cliToken) {
    try {
        if (!is_initialized_) {
            com::ft::sdk::internal::LoggerManager::getInstance().enableLog(enableSdkLog);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug(
                "InstallSDK: ClientToken: {}", MaskToken(cliToken));
            
            // Create SDK instance using factory
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: Getting SDK from factory...");
            sdk_ = com::ft::sdk::FTSDKFactory::get("");
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: SDK instance created");
            
            // Initialize SDK environment
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: Calling sdk_->init()...");
            sdk_->init();
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: SDK init done");
            
            // Install with config
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: Calling sdk_->install()...");
            sdk_->install(config);
            com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InstallSDK: SDK install done");
            
            is_initialized_ = true;
        }
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("Failed to install SDK: {}", e.what());
        throw;
    }
}

void FTSDKAdapter::InitRUMWithConfig(com::ft::sdk::FTRUMConfig& config) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("InitRUMWithConfig: SDK not initialized!");
        throw std::runtime_error("SDK not initialized. Call InstallSDK first.");
    }
    com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InitRUMWithConfig: Calling sdk_->initRUMWithConfig()...");
    try {
        sdk_->initRUMWithConfig(config);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("InitRUMWithConfig: sdk_->initRUMWithConfig() returned");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("InitRUMWithConfig: Exception in sdk_->initRUMWithConfig(): {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("InitRUMWithConfig: Unknown exception in sdk_->initRUMWithConfig()!");
        throw;
    }
}

void FTSDKAdapter::StartAction(const std::string& actionName, const std::string& actionType) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("StartAction: SDK not initialized!");
        throw std::runtime_error("SDK not initialized.");
    }
    com::ft::sdk::internal::LoggerManager::getInstance().logDebug("StartAction: Calling sdk_->startAction({}, {})...", actionName, actionType);
    try {
        sdk_->startAction(actionName, actionType);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("StartAction: sdk_->startAction() returned");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("StartAction: Exception in sdk_->startAction(): {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("StartAction: Unknown exception in sdk_->startAction()!");
        throw;
    }
}

void FTSDKAdapter::AddAction(const std::string& actionName, const std::string& actionType, 
                              long duration, long startTime) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AddAction: SDK not initialized!");
        throw std::runtime_error("SDK not initialized.");
    }
    com::ft::sdk::internal::LoggerManager::getInstance().logDebug("AddAction: Calling sdk_->addAction({}, {}, {}, {})...", 
              actionName, actionType, duration, startTime);
    try {
        sdk_->addAction(actionName, actionType, duration, startTime);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("AddAction: sdk_->addAction() returned");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AddAction: Exception in sdk_->addAction(): {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AddAction: Unknown exception in sdk_->addAction()!");
        throw;
    }
}

void FTSDKAdapter::StartView(const std::string& viewName) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("StartView: SDK not initialized, ignoring");
        return;
    }
    sdk_->startView(viewName);
}

void FTSDKAdapter::StopView() {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("StopView: SDK not initialized, ignoring");
        return;
    }
    sdk_->stopView();
}

void FTSDKAdapter::AddError(const std::string& stack, const std::string& message,
                            com::ft::sdk::RUMErrorType errorType, com::ft::sdk::AppState state) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AddError: SDK not initialized, ignoring");
        return;
    }
    sdk_->addError(stack, message, errorType, state);
}

void FTSDKAdapter::StartResource(const std::string& resourceId) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("StartResource: SDK not initialized, ignoring");
        return;
    }
    
    try {
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("StartResource: About to call sdk_->startResource({})", resourceId);
        
    sdk_->startResource(resourceId);
        com::ft::sdk::internal::LoggerManager::getInstance().logDebug("StartResource: sdk_->startResource() returned successfully");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("StartResource: Exception in sdk_->startResource(): {}", e.what());
        // Do not throw to avoid affecting HTTP requests.
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("StartResource: Unknown exception in sdk_->startResource()");
        // Do not throw to avoid affecting HTTP requests.
    }
}

void FTSDKAdapter::StopResource(const std::string& resourceId) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("StopResource: SDK not initialized, ignoring");
        return;
    }
    sdk_->stopResource(resourceId);
}

void FTSDKAdapter::AddResource(const std::string& resourceId,
                               const com::ft::sdk::ResourceParams& params,
                               const com::ft::sdk::NetStatus& netStatus) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AddResource: SDK not initialized, ignoring");
        return;
    }
    sdk_->addResource(resourceId, params, netStatus);
}

void FTSDKAdapter::InitLogWithConfig(com::ft::sdk::FTLogConfig& config) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("InitLogWithConfig: SDK not initialized, ignoring");
        return;
    }
    try {
        sdk_->initLogWithConfig(config);
        is_log_initialized_ = true;
        com::ft::sdk::internal::LoggerManager::getInstance().logInfo("InitLogWithConfig: Log config initialized successfully");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("InitLogWithConfig: Exception: {}", e.what());
        is_log_initialized_ = false;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("InitLogWithConfig: Unknown exception");
        is_log_initialized_ = false;
    }
}

void FTSDKAdapter::AddLog(const std::string& content, com::ft::sdk::LogLevel level) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AddLog: SDK not initialized, ignoring");
        return;
    }
    if (!is_log_initialized_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AddLog: Log config not initialized (is_log_initialized_=false), skipping. Please call logConfig first!");
        return;
    }
    try {
        sdk_->addLog(content, level);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AddLog: Exception: {}", e.what());
        // Ignore the error, don't crash the app
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AddLog: Unknown exception");
        // Ignore the error, don't crash the app
    }
}

void FTSDKAdapter::InitTraceWithConfig(com::ft::sdk::FTTraceConfig& config) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("InitTraceWithConfig: SDK not initialized, ignoring");
        return;
    }
    sdk_->initTraceWithConfig(config);
}

std::map<std::string, std::string> FTSDKAdapter::GenerateTraceHeader(const std::string& url) {
    try {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("GenerateTraceHeader: SDK not initialized, returning empty");
        return {};
    }
    return sdk_->generateTraceHeader(url);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("GenerateTraceHeader: Exception: {}", e.what());
        return {};
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("GenerateTraceHeader: Unknown exception");
        return {};
    }
}

std::map<std::string, std::string> FTSDKAdapter::GenerateTraceHeader(const std::string& resourceId, const std::string& url) {
    try {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("GenerateTraceHeader: SDK not initialized, returning empty");
        return {};
    }
    return sdk_->generateTraceHeader(resourceId, url);
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("GenerateTraceHeader: Exception: {}", e.what());
        return {};
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("GenerateTraceHeader: Unknown exception");
        return {};
    }
}

void FTSDKAdapter::BindUserData(com::ft::sdk::UserData& userData) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("BindUserData: SDK not initialized, ignoring");
        return;
    }
    sdk_->bindUserData(userData);
}

void FTSDKAdapter::UnbindUserData() {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("UnbindUserData: SDK not initialized, ignoring");
        return;
    }
    sdk_->unbindUserData();
}

void FTSDKAdapter::FlushSyncData() {
    // C++ SDK doesn't have a direct flush method
    // Data sync is handled automatically by DataSyncManager
    // This is a no-op for now
}

void FTSDKAdapter::ClearAllData() {
    try {
        com::ft::sdk::internal::LineDBManager::getInstance().clearDB();
        com::ft::sdk::internal::LoggerManager::getInstance().logInfo("ClearAllData: Successfully cleared all cached data");
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("ClearAllData: Exception: {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("ClearAllData: Unknown exception");
        throw;
    }
}

void FTSDKAdapter::AppendRUMGlobalContext(const std::map<std::string, std::string>& globalContext) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AppendRUMGlobalContext: SDK not initialized, ignoring");
        return;
    }
    
    try {
        auto& rumConfig = com::ft::sdk::internal::FTSDKConfigManager::getInstance().getRUMConfig();
        
        // Get current custom_keys
        auto& currentGlobalContext = rumConfig.getGlobalContext();
        std::set<std::string> customKeys;
        
        // Parse existing custom_keys if present
        auto customKeysIt = currentGlobalContext.find(com::ft::sdk::constants::KEY_RUM_CUSTOM_KEYS);
        if (customKeysIt != currentGlobalContext.end()) {
            try {
                auto jsonArray = nlohmann::json::parse(customKeysIt->second);
                if (jsonArray.is_array()) {
                    for (const auto& item : jsonArray) {
                        if (item.is_string()) {
                            customKeys.insert(item.get<std::string>());
                        }
                    }
                }
            } catch (const std::exception& e) {
                com::ft::sdk::internal::LoggerManager::getInstance().logError("AppendRUMGlobalContext: Error parsing custom_keys: {}", e.what());
            }
        }
        
        // Add new global context entries
        for (const auto& entry : globalContext) {
            rumConfig.addGlobalContext(entry.first, entry.second);
            customKeys.insert(entry.first);
        }
        
        // Update custom_keys JSON array
        std::vector<std::string> customKeysVector(customKeys.begin(), customKeys.end());
        std::string customKeysJson = com::ft::sdk::internal::utils::convertVector2Json(customKeysVector);
        rumConfig.addGlobalContext(com::ft::sdk::constants::KEY_RUM_CUSTOM_KEYS, customKeysJson);
        
        com::ft::sdk::internal::LoggerManager::getInstance().logInfo("AppendRUMGlobalContext: Successfully added {} entries", globalContext.size());
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AppendRUMGlobalContext: Exception: {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AppendRUMGlobalContext: Unknown exception");
        throw;
    }
}

void FTSDKAdapter::AppendLogGlobalContext(const std::map<std::string, std::string>& globalContext) {
    if (!sdk_) {
        com::ft::sdk::internal::LoggerManager::getInstance().logWarn("AppendLogGlobalContext: SDK not initialized, ignoring");
        return;
    }
    
    try {
        auto& logConfig = com::ft::sdk::internal::FTSDKConfigManager::getInstance().getLogPipeConfig();
        
        // Add new global context entries
        for (const auto& entry : globalContext) {
            logConfig.addGlobalContext(entry.first, entry.second);
        }
        
        com::ft::sdk::internal::LoggerManager::getInstance().logInfo("AppendLogGlobalContext: Successfully added {} entries", globalContext.size());
    } catch (const std::exception& e) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AppendLogGlobalContext: Exception: {}", e.what());
        throw;
    } catch (...) {
        com::ft::sdk::internal::LoggerManager::getInstance().logError("AppendLogGlobalContext: Unknown exception");
        throw;
    }
}

void FTSDKAdapter::Deinit() {
    if (sdk_ && is_initialized_) {
        sdk_->deinit();
        is_initialized_ = false;
    }
}

}  // namespace ft_mobile_agent_flutter

