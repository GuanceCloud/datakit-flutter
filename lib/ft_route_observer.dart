import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

/// Monitor page sleep and wake
@Deprecated(
    "Just remove. Same staff will be done in FTRouteObserver and FTDialogRouteFilterObserver")
class FTLifeRecycleHandler {

  void initObserver() {}

  void removeObserver() {}
}

/// When using route navigation, monitor page lifecycle, filter DialogRoute and PopupRoute type components
class FTDialogRouteFilterObserver extends FTRouteObserver {
  /// [filterOnlyNoSettingName] Only filter data where [RouteSettings.name] is null
  /// [filterPopRoute] Filter PopupRoute type
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

/// When using route navigation, monitor page lifecycle
class FTRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  RouteFilter? _routeFilter;

  ///
  /// [routeFilter] Set filter, return true for items to be filtered, return false for items not to be filtered
  ///
  FTRouteObserver({RouteFilter? routeFilter}) {
    this._routeFilter = routeFilter;
  }

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
      FTLifeRecycleMonitor.instance._currentPageName = name;
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

class FTLifeRecycleMonitor with WidgetsBindingObserver {
  static final FTLifeRecycleMonitor instance = FTLifeRecycleMonitor._internal();
  String _currentPageName = "";

  // Private constructor
  FTLifeRecycleMonitor._internal() {
    WidgetsBinding.instance.addObserver(this);
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
