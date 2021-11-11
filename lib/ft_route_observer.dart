
import 'package:flutter/widgets.dart';

import 'ft_rum.dart';
class FTRouteObserver extends RouteObserver<PageRoute<dynamic>> {

  FTRouteObserver();

  Future<void> _sendScreenView(Route? route, Route? previousRoute) async {
    String previousRouteName = '';
    if (previousRoute is PageRoute) {
      if (previousRoute.settings.name != null) {
        previousRouteName = previousRoute.settings.name!;
        await FTRUMManager().stopView();
      }
    }
    if (route is PageRoute) {
      final routeName = route.settings.name;
      if (routeName != null) {
        await FTRUMManager().starView(routeName,previousRouteName);
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
