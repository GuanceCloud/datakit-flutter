#include "ft_mobile_agent_flutter_plugin.h"
#include "method_channel_handler.h"

#include <flutter/standard_method_codec.h>
#include <flutter_plugin_registrar.h>
#include <memory>

// Define FLUTTER_PLUGIN_EXPORT for dllexport
#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

namespace ft_mobile_agent_flutter {

// static
void FTMobileAgentFlutter::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<FTMobileAgentFlutter>();
  
  // Create method channel
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "ft_mobile_agent_flutter",
          &flutter::StandardMethodCodec::GetInstance());

  // Set method call handler
  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  // Store channel and plugin
  plugin->channel_ = std::move(channel);
  registrar->AddPlugin(std::move(plugin));
}

FTMobileAgentFlutter::FTMobileAgentFlutter() {}

FTMobileAgentFlutter::~FTMobileAgentFlutter() {}

void FTMobileAgentFlutter::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  // Delegate to method channel handler
  MethodChannelHandler::HandleMethodCall(method_call, std::move(result));
}

}  // namespace ft_mobile_agent_flutter

// Export the registration function with C linkage
extern "C" {
FLUTTER_PLUGIN_EXPORT void FTMobileAgentFlutterRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ft_mobile_agent_flutter::FTMobileAgentFlutter::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
}

