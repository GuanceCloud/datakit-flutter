import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';


/// Set class name to [RouteSettings] name for use in [FTRUMManager] starView
class FTMaterialPageRoute<T> extends MaterialPageRoute<T> {
  FTMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: builder,
            settings: settings ??
                RouteSettings(
                    name: _getViewName(builder.runtimeType.toString())),
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog);
}

/// Use regex to filter out class name
String? _getViewName(String name) {
  try {
    var regexString = r'\(BuildContext\) => (.*)';
    var regExp = RegExp(regexString);
    var matches = regExp.allMatches(name);
    return matches.first.group(1).toString();
  } catch (e, stacktrace) {
    FTRUMManager().addError("get viewName error", stacktrace);
    return null;
  }
}
