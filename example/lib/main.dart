// ignore_for_file: use_key_in_widget_constructors

import 'package:example/router_examples/go_router_app.dart';
import 'package:example/router_examples/routermaster_app.dart';
import 'package:example/router_examples/url_router.dart';
import 'package:example/router_examples/vrouter_app.dart';
import 'package:flutter/material.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';

import 'widgets.dart';

/// This demo shows routed widget switcher working with various
/// popular routing libraries. Because the switcher binds directly
/// to the Router, it works regardless of which router implementation
/// is used.
///
/// To test, switch between the various paths using your keyboard.
/// Observe as the Sidebar changes it's children according to current
/// location.
void main() {
  runApp(MultiAppTestRig(
    testNames: ['GoRouter', 'VRouter', 'RouteMaster', 'UrlRouter'],
    tests: [
      (_) => GoRouterApp(),
      (_) => VRouterApp(),
      (_) => RouteMasterApp(),
//      (_) => BeamerApp(),
      (_) => UrlRouterApp(),
    ],
  ));
  //runApp(NestedAppExample());
}

/// Embedded within any of the example app scaffolds, this widget uses
/// `RoutedWidgetSwitcher` to switch children when router location changes.
class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget buildSideBarBg(Widget child) => Material(child: SizedBox(width: 180, child: child));
    return buildSideBarBg(
      RoutedSwitcher(
        builders: (_) => [
          // Wildcard will match any route
          Routed('*', MainMenu.new),
          Routed('/dashboard', DashboardMenu.new),
          Routed('/settings', SettingsMenu.new),
        ],
      ),
    );
  }
}
