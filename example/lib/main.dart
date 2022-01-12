import 'package:example/router_examples/beamer_app.dart';
import 'package:example/router_examples/routermaster_app.dart';
import 'package:flutter/material.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';

import 'router_examples/go_router_app.dart';
import 'router_examples/vrouter_app.dart';
import 'widgets.dart';

void main() {
  runApp(MultiAppTestRig(
    tests: [
      (_) => GoRouterApp(),
      (_) => VRouterApp(),
      (_) => RouteMasterApp(),
      (_) => BeamerApp(),
    ],
  ));
}

/// Embedded within any of the example app scaffolds, this widget uses
/// `RoutedWidgetSwitcher` to switch children when router location changes.
class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buildSideBarBg(Widget child) => Material(child: SizedBox(width: 180, child: child));
    return buildSideBarBg(
      RoutedWidgetSwitcher(
        builders: [
          PathBuilder('*', builder: (_) => const MainMenu()),
          PathBuilder('/dashboard', builder: (_) => const DashboardMenu()),
          PathBuilder('/settings', builder: (_) => const SettingsMenu()),
        ],
      ),
    );
  }
}
