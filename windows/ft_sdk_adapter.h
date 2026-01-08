#ifndef FT_SDK_ADAPTER_H_
#define FT_SDK_ADAPTER_H_

#include <memory>
#include <string>
#include <map>
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable : 4251)
#endif
#include "FTSDK.h"
#include "FTSDKConfig.h"
#include "FTSDKDataContracts.h"
#ifdef _MSC_VER
#pragma warning(pop)
#endif

namespace ft_mobile_agent_flutter {

/**
 * FTSDK Adapter
 * Singleton adapter class that wraps C++ SDK calls
 */
class FTSDKAdapter {
public:
    // Get singleton instance
    static FTSDKAdapter& GetInstance();
    
    // Disable copy and assignment
    FTSDKAdapter(const FTSDKAdapter&) = delete;
    FTSDKAdapter& operator=(const FTSDKAdapter&) = delete;
    
    // SDK initialization
    void InstallSDK(com::ft::sdk::FTSDKConfig& config, bool enableSdkLog, const std::string& cliToken);
    
    // RUM methods
    void InitRUMWithConfig(com::ft::sdk::FTRUMConfig& config);
    void StartAction(const std::string& actionName, const std::string& actionType);
    void AddAction(const std::string& actionName, const std::string& actionType, long duration, long startTime);
    void StartView(const std::string& viewName);
    void StopView();
    void AddError(const std::string& stack, const std::string& message, 
                  com::ft::sdk::RUMErrorType errorType, com::ft::sdk::AppState state);
    void StartResource(const std::string& resourceId);
    void StopResource(const std::string& resourceId);
    void AddResource(const std::string& resourceId, 
                     const com::ft::sdk::ResourceParams& params,
                     const com::ft::sdk::NetStatus& netStatus);
    
    // Log methods
    void InitLogWithConfig(com::ft::sdk::FTLogConfig& config);
    void AddLog(const std::string& content, com::ft::sdk::LogLevel level);
    
    // Trace methods
    void InitTraceWithConfig(com::ft::sdk::FTTraceConfig& config);
    std::map<std::string, std::string> GenerateTraceHeader(const std::string& url);
    std::map<std::string, std::string> GenerateTraceHeader(const std::string& resourceId, const std::string& url);
    
    // User data methods
    void BindUserData(com::ft::sdk::UserData& userData);
    void UnbindUserData();
    
    // Utility methods
    void FlushSyncData();
    void ClearAllData();
    void AppendRUMGlobalContext(const std::map<std::string, std::string>& globalContext);
    void AppendLogGlobalContext(const std::map<std::string, std::string>& globalContext);
    void Deinit();
    bool IsInitialized() const { return is_initialized_; }
    
private:
    FTSDKAdapter() = default;
    ~FTSDKAdapter() = default;
    
    // SDK instance
    std::unique_ptr<com::ft::sdk::FTSDK> sdk_;
    bool is_initialized_ = false;
    bool is_log_initialized_ = false;
};

}  // namespace ft_mobile_agent_flutter

#endif  // FT_SDK_ADAPTER_H_

