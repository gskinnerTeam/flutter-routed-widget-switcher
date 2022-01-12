import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:routed_widget_switcher/router_utils.dart';
export 'router_utils.dart';

/// Wraps a [PathWidgetSwitcher] and injects it with the current Router location.
/// Binds to the current RouterDelegate and RouteInformationProvider for rebuilds.
class RoutedWidgetSwitcher extends StatefulWidget {
  const RoutedWidgetSwitcher({
    Key? key,
    required this.builders,
    this.duration,
    this.transitionBuilder,
    this.caseSensitive = false,
  }) : super(key: key);

  /// Duration of the animation when switching widgets
  final Duration? duration;

  /// Allows custom animations when switching widgets, defaults to `AnimatedSwitcher.defaultTransitionBuilder`
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// A list of all matching paths and their associated builder method.
  final List<PathBuilder> builders;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a per path basis.
  final bool caseSensitive;

  @override
  State<RoutedWidgetSwitcher> createState() => _RoutedWidgetSwitcherState();
}

class _RoutedWidgetSwitcherState extends State<RoutedWidgetSwitcher> {
  RouterDelegate? delegate;
  RouteInformationProvider? provider;
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() {
      delegate = Router.of(context).routerDelegate;
      delegate?.addListener(_handleRouteChanged);
      provider = Router.of(context).routeInformationProvider;
      provider?.addListener(_handleRouteChanged);
    });
  }

  @override
  void dispose() {
    delegate?.removeListener(_handleRouteChanged);
    provider?.removeListener(_handleRouteChanged);
    super.dispose();
  }

  void _handleRouteChanged() {
    if (mounted == false) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => PathWidgetSwitcher(
        builders: widget.builders,
        location: RouterUtils.getLocation(context),
        caseSensitive: widget.caseSensitive,
        duration: widget.duration,
        transitionBuilder: widget.transitionBuilder,
      );
}

/// Takes a list of [PathBuilder]s and switches between them based on the current `location` value.
/// Uses `pathToRegExp` lib to perform pattern matching.
/// Uses [AnimatedSwitcher] to transition between children.
class PathWidgetSwitcher extends StatelessWidget {
  const PathWidgetSwitcher({
    Key? key,
    required this.builders,
    required this.location,
    this.duration,
    this.transitionBuilder,
    this.caseSensitive = false,
  }) : super(key: key);

  /// Duration of the animation when switching widgets
  final Duration? duration;

  /// Allows custom animations when switching widgets, defaults to `AnimatedSwitcher.defaultTransitionBuilder`
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// A list of all matching paths and their associated builder method.
  final List<PathBuilder> builders;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a per path basis.
  final bool caseSensitive;

  /// The current location, used to determine the current matching builder.
  final String location;

  @override
  Widget build(BuildContext context) {
    Widget? routedWidget = findRoutedWidget(location)?.builder(context);
    return AnimatedSwitcher(
      duration: duration ?? const Duration(milliseconds: 350),
      child: routedWidget ?? Center(child: Text('No match found for: $location')),
      transitionBuilder: transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
    );
  }

  /// Find a matching RoutedWidget for a given location.
  @visibleForTesting
  PathBuilder? findRoutedWidget(String loc) {
    List<PathBuilder> matches = builders.where((route) {
      if (route.path == '*') return true;
      final regEx = pathToRegExp(
        route.path,
        prefix: route.prefix,
        caseSensitive: route.caseSensitive ?? caseSensitive,
      );
      return regEx.hasMatch(loc);
    }).toList();
    return getMostSpecificMatch(loc, matches);
  }

  /// Given a list of possible matches, return the most exact one.
  @visibleForTesting
  PathBuilder? getMostSpecificMatch(String loc, List<PathBuilder> matches) {
    // Return null if we have no matches
    if (matches.isEmpty) return null;
    // If we have an exact match, use that
    for (var m in matches) {
      if (m.path == loc) return m;
    }
    // Next, take the first non-prefixed match we see
    for (var m in matches) {
      if (!m.prefix) return m;
    }
    // Last resort, take the longest match which we'll assume is most precise.
    // Adds special logic to make sure '*' gets sorted after something like '/'
    // TODO: This should sort by number of matched segments first, and then length?
    matches.sort((a, b) {
      if (b.path == '*') return -1;
      return a.path.length > b.path.length ? -1 : 1;
    });

    return matches[0];
  }
}

class PathBuilder {
  PathBuilder(this.path, {required this.builder, this.prefix = true, this.caseSensitive});
  final String path;
  final bool prefix;
  final bool? caseSensitive;
  final WidgetBuilder builder;
}
