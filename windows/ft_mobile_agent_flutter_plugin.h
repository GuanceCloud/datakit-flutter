#ifndef FLUTTER_PLUGIN_FT_MOBILE_AGENT_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_FT_MOBILE_AGENT_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

namespace ft_mobile_agent_flutter {

// Plugin class for ft_mobile_agent_flutter Windows implementation
class FTMobileAgentFlutter : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FTMobileAgentFlutter();

  virtual ~FTMobileAgentFlutter();

  // Disallow copy and assign
  FTMobileAgentFlutter(const FTMobileAgentFlutter&) = delete;
  FTMobileAgentFlutter& operator=(const FTMobileAgentFlutter&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Method channel for communication with Flutter
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

}  // namespace ft_mobile_agent_flutter

#endif  // FLUTTER_PLUGIN_FT_MOBILE_AGENT_FLUTTER_PLUGIN_H_

