import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

///使用路由跳转时，监控页面生命周期
class FTRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  FTRouteObserver();

  Future<void> _sendScreenView(Route? route, Route? previousRoute) async {
    String name = "";

    if (previousRoute != null) {
      await FTRUMManager().stopView();
    }
    if (route is PageRoute) {
      name = route.settings.name ?? "";
      if (name.length > 0) {
        await FTRUMManager().starView(name);
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
    _sendScreenView(previousRoute, route);
    super.didPop(route, previousRoute);
  }
}
