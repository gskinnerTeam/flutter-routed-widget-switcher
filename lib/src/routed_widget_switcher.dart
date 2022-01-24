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
  RouterDelegate? _delegate;
  RouteInformationProvider? _provider;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      _delegate = Router.of(context).routerDelegate;
      _delegate?.addListener(_handleRouteChanged);
      _provider = Router.of(context).routeInformationProvider;
      _provider?.addListener(_handleRouteChanged);
    });
  }

  @override
  void dispose() {
    _delegate?.removeListener(_handleRouteChanged);
    _provider?.removeListener(_handleRouteChanged);
    super.dispose();
  }

  void _handleRouteChanged() {
    if (mounted == false) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String url = RouterUtils.getUrl(context);
    return PathSwitcher(
      path: url,
      builders: widget.builders,
      caseSensitive: widget.caseSensitive,
      duration: widget.duration,
      transitionBuilder: widget.transitionBuilder,
      unknownRouteBuilder: widget.unknownRouteBuilder,
      // relativePaths: widget.relativePaths,
    );
  }
}
