import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///使用路由跳转时，监控页面生命周期
class FTRouteObserver extends RouteObserver<PageRoute<dynamic>> {

  FTRouteObserver();

  Future<void> _sendScreenView(Route? route, Route? previousRoute) async {
    String previousRouteName = '';
    String name = "";
    if (previousRoute != null && previousRoute is MaterialPageRoute) {
        previousRouteName = previousRoute.builder.toString();
    }

    if (previousRoute != null) {
         FTRUMManager().stopView();
    }
    if (route is MaterialPageRoute) {
        name = route.settings.name != null?route.settings.name!: route.builder.toString();
      if (name.length > 0) {
         FTRUMManager().starView(name,previousRouteName);
      }
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _sendScreenView(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _sendScreenView(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _sendScreenView(route, previousRoute);
    super.didPop(route, previousRoute);
  }
}
