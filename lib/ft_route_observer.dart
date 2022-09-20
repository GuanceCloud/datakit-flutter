import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

///监控页面休眠和唤醒
class FTLifeRecycleHandler with WidgetsBindingObserver {
  static final FTLifeRecycleHandler _singleton =
      FTLifeRecycleHandler._internal();

  factory FTLifeRecycleHandler() {
    return _singleton;
  }

  FTLifeRecycleHandler._internal();

  String _currentPageName = "";

  void initObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  void removeObserver() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FTRUMManager().stopView();
    } else if (state == AppLifecycleState.resumed) {
      FTRUMManager().starView(_currentPageName);
    }
  }
}

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
        FTLifeRecycleHandler()._currentPageName = name;
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
