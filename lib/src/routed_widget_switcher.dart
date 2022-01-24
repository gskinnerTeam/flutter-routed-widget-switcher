import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:routed_widget_switcher/src/router_utils.dart';
import 'path_widget_switcher.dart';

/// Wraps a [PathSwitcher] and injects it with the current Router location.
/// Binds to the current RouterDelegate and RouteInformationProvider for rebuilds.
class RoutedSwitcher extends StatefulWidget {
  const RoutedSwitcher({
    Key? key,
    required this.builders,
    this.duration,
    this.transitionBuilder,
    this.caseSensitive = false,
    this.relativePaths = false,
    this.unknownRouteBuilder,
  }) : super(key: key);

  /// Duration of the animation when switching widgets
  final Duration? duration;

  /// Allows custom animations when switching widgets, defaults to `AnimatedSwitcher.defaultTransitionBuilder`
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// A list of all matching paths and their associated builder method.
  final List<Routed> Function(RoutedInfo info) builders;
  final WidgetBuilder? unknownRouteBuilder;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a per path basis.
  final bool caseSensitive;

  final bool relativePaths;

  @override
  State<RoutedSwitcher> createState() => RoutedSwitcherState();
}

class RoutedSwitcherState extends State<RoutedSwitcher> {
  @override
  Widget build(BuildContext context) {
    final routeInfoProvider = Router.of(context).routeInformationProvider;
    if (routeInfoProvider == null) throw ('RoutedSwitcher only works with Routers that have an infoProvider.');
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        Router.of(context).routerDelegate,
        routeInfoProvider,
      ]),
      builder: (_, __) {
        return PathSwitcher(
          path: RouterUtils.getUrl(context),
          builders: widget.builders,
          caseSensitive: widget.caseSensitive,
          duration: widget.duration,
          transitionBuilder: widget.transitionBuilder,
          unknownRouteBuilder: widget.unknownRouteBuilder,
          // relativePaths: widget.relativePaths,
        );
      },
    );
  }
}
