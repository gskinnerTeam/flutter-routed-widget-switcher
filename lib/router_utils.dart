import 'package:flutter/widgets.dart';

class RouterUtils {
  RouterUtils._();
  static String getLocation(BuildContext context) {
    final r = Router.of(context);
    final parser = r.routeInformationParser;
    final config = r.routerDelegate.currentConfiguration;
    return parser?.restoreRouteInformation(config)?.location ?? '/';
  }
}
