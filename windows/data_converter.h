#ifndef DATA_CONVERTER_H_
#define DATA_CONVERTER_H_

#include <flutter/encodable_value.h>
#include <string>
#include <map>
#include <vector>
#include <memory>

// Forward declarations
namespace com::ft::sdk {
    class FTSDKConfig;
    class FTRUMConfig;
    class FTLogConfig;
    class FTTraceConfig;
    class UserData;
    struct ResourceParams;
    struct NetStatus;
    enum class AppState : int;
    enum class LogLevel : int;
    enum class TraceType : char;
    enum class RUMErrorType : int;
    enum class EnvType : int;
}

namespace ft_mobile_agent_flutter {

/**
 * Data converter utility class
 * Converts between Flutter EncodableValue and C++ SDK types
 */
class DataConverter {
public:
    // SDK Config conversion
    static std::unique_ptr<com::ft::sdk::FTSDKConfig> ConvertToSDKConfig(
        const flutter::EncodableMap& args);
    
    // RUM Config conversion
    static std::unique_ptr<com::ft::sdk::FTRUMConfig> ConvertToRUMConfig(
        const flutter::EncodableMap& args);
    
    // Log Config conversion
    static std::unique_ptr<com::ft::sdk::FTLogConfig> ConvertToLogConfig(
        const flutter::EncodableMap& args);
    
    // Trace Config conversion
    static std::unique_ptr<com::ft::sdk::FTTraceConfig> ConvertToTraceConfig(
        const flutter::EncodableMap& args);
    
    // User Data conversion
    static std::unique_ptr<com::ft::sdk::UserData> ConvertToUserData(
        const flutter::EncodableMap& args);
    
    // Resource Params conversion
    static std::unique_ptr<com::ft::sdk::ResourceParams> ConvertToResourceParams(
        const flutter::EncodableMap& args);
    
    // Helper methods for type conversion
    static std::string GetString(const flutter::EncodableMap& map, const std::string& key, const std::string& defaultValue = "");
    static bool GetBool(const flutter::EncodableMap& map, const std::string& key, bool defaultValue = false);
    static double GetDouble(const flutter::EncodableMap& map, const std::string& key, double defaultValue = 0.0);
    static int GetInt(const flutter::EncodableMap& map, const std::string& key, int defaultValue = 0);
    static flutter::EncodableMap GetMap(const flutter::EncodableMap& map, const std::string& key);
    static flutter::EncodableList GetList(const flutter::EncodableMap& map, const std::string& key);
    static std::map<std::string, std::string> ConvertToStringMap(const flutter::EncodableMap& map);
    
    // Enum conversions
    static com::ft::sdk::AppState ConvertToAppState(int value);
    static com::ft::sdk::LogLevel ConvertToLogLevel(int value);
    static com::ft::sdk::TraceType ConvertToTraceType(int value);
    static com::ft::sdk::RUMErrorType ConvertToRUMErrorType(const std::string& errorType);
    static com::ft::sdk::EnvType ConvertToEnvType(const std::string& env);
    
    // Convert C++ types to Flutter EncodableValue
    static flutter::EncodableValue ConvertToEncodableValue(const std::map<std::string, std::string>& map);
    static flutter::EncodableValue ConvertToEncodableValue(const std::string& str);
    static flutter::EncodableValue ConvertToEncodableValue(int value);
    static flutter::EncodableValue ConvertToEncodableValue(bool value);
};

}  // namespace ft_mobile_agent_flutter

#endif  // DATA_CONVERTER_H_

