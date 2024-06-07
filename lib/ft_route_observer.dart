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

/// 使用路由跳转时，监控页面生命周期，过滤 DialogRoute 与 PopupRoute 类型的组件
class FTDialogRouteFilterObserver extends FTRouteObserver {
  /// [filterOnlyNoSettingName] 仅过滤 [RouteSettings.name] 为 null 的数据
  /// [filterPopRoute] 过滤 PopupRoute 类型的
  FTDialogRouteFilterObserver({
    bool filterOnlyNoSettingName = false,
    bool filterPopRoute = true,
  }) {
    _routeFilter = (route, pre) {
      if (route is DialogRoute || (filterPopRoute && route is PopupRoute)) {
        if (!filterOnlyNoSettingName) {
          return true;
        }
        return route?.settings.name == null;
      }
      if (pre is DialogRoute || (filterPopRoute && pre is PopupRoute)) {
        if (!filterOnlyNoSettingName) {
          return true;
        }
        return pre?.settings.name == null;
      }
      return false;
    };
  }
}

typedef RouteFilter = bool Function(Route? route, Route? previousRoute);

///使用路由跳转时，监控页面生命周期
class FTRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  RouteFilter? _routeFilter;

  ///
  /// [routeFilter] 设置过滤，需要过滤的返回 true，不需要过滤返回 false
  ///
  FTRouteObserver({RouteFilter? routeFilter}) : this._routeFilter = routeFilter;

  Future<void> sendScreenView(Route? route, Route? previousRoute) async {
    if (_routeFilter?.call(route, previousRoute) ?? false) {
      return;
    }

    String name = "";

    if (previousRoute != null) {
      await FTRUMManager().stopView();
    }

    if (route != null) {
      name = route.settings.name ?? "";
      if (name.length == 0) {
        name = route.runtimeType.toString();
      }
      await FTRUMManager().starView(name);
      FTLifeRecycleHandler()._currentPageName = name;
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    sendScreenView(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    sendScreenView(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    sendScreenView(previousRoute, route);
    super.didPop(route, previousRoute);
  }
}
