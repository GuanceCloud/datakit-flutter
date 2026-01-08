#ifndef METHOD_CHANNEL_HANDLER_H_
#define METHOD_CHANNEL_HANDLER_H_

#include <flutter/method_channel.h>
#include <flutter/encodable_value.h>
#include <memory>

namespace ft_mobile_agent_flutter {

/**
 * Method channel handler
 * Handles all method calls from Flutter and routes them to appropriate SDK calls
 */
class MethodChannelHandler {
public:
    // Handle method call from Flutter
    static void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
private:
    // Method handlers
    static void HandleConfig(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleFlushSyncData(
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleBindUser(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleUnbindUser(
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMConfig(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMStartAction(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMAddAction(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMStartView(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMStopView(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMAddError(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMStartResource(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMStopResource(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleRUMAddResource(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleLogConfig(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleLogging(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleTraceConfig(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleGetTraceHeader(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleAppendGlobalContext(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleAppendRUMGlobalContext(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleAppendLogGlobalContext(
        const flutter::EncodableMap& args,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    
    static void HandleClearAllData(
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ft_mobile_agent_flutter

#endif  // METHOD_CHANNEL_HANDLER_H_

