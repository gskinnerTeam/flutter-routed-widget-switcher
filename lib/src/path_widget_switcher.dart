import 'package:flutter/material.dart';
import 'package:path_to_regexp/path_to_regexp.dart';

/// Takes a list of [Routed]s and switches between them based on the current `location` value.
/// Uses `pathToRegExp` lib to perform pattern matching.
/// Uses [AnimatedSwitcher] to transition between children.
class PathSwitcher extends StatefulWidget {
  const PathSwitcher({
    Key? key,
    required this.path,
    required this.builders,
    this.duration,
    this.transitionBuilder,
    this.caseSensitive = false,
    this.unknownRouteBuilder,
    // this.relativePaths = true,
  }) : super(key: key);

  /// Duration of the animation when switching widgets
  final Duration? duration;

  /// Allows custom animations when switching widgets, defaults to `AnimatedSwitcher.defaultTransitionBuilder`
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// A list of all matching paths and their associated builder method.
  final List<Routed> Function(RoutedInfo info) builders;

  /// Optional builder when no match is found
  final WidgetBuilder? unknownRouteBuilder;

  // TODO: caseSensitive should inherit from parent recursively
  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a per path basis.
  final bool caseSensitive;

  /// The current location, used to determine the current matching builder.
  final String path;

  @override
  State<PathSwitcher> createState() => PathSwitcherState();
}

class PathSwitcherState extends State<PathSwitcher> {
  /// Find a matching RoutedWidget for a given location.
  @visibleForTesting
  Routed? findRoutedWidget(String location, [RoutedInfo? info]) {
    location = Uri.tryParse(location)?.path ?? location; // strip query args when matching
    List<Routed> matches = widget.builders.call(info ?? _createRoutedInfo()).where((routed) {
      if (routed.value == '*') return true;
      String routedPath = routed.resolveFullRoute(context);
      final regEx = pathToRegExp(
        routedPath,
        prefix: routed.prefix,
        caseSensitive: widget.caseSensitive,
      );
      return regEx.matchAsPrefix(location) != null;
    }).toList();
    final match = getMostSpecificMatch(location, matches);
    return match;
  }

  /// Given a list of possible matches, return the most exact one.
  @visibleForTesting
  Routed? getMostSpecificMatch(String location, List<Routed> matches) {
    // Return null if we have no matches
    if (matches.isEmpty) return null;
    // If we have an exact match, use that
    for (var m in matches) {
      if (m.value == location) return m;
    }
    // Next, take the first non-prefixed match we see
    for (var m in matches) {
      if (!m.prefix) return m;
    }
    // Last resort, take the longest match which we'll assume is most precise.
    // Adds special logic to make sure '*' gets sorted after something like '/'
    // TODO: This should sort by number of matched segments first, and then length?
    matches.sort((a, b) {
      if (b.value == '*') return -1;
      return a.value.length > b.value.length ? -1 : 1;
    });
    return matches[0];
  }

  Map<String, String> _extractPathParams(String path, String url, {required bool prefix}) {
    final uri = Uri.tryParse(url);
    if (uri == null) return {};
    final parameters = <String>[];
    final regExp = pathToRegExp(
      path,
      prefix: prefix,
      caseSensitive: widget.caseSensitive,
      parameters: parameters,
    );
    final regExpMatch = regExp.matchAsPrefix(uri.path);
    if (regExpMatch != null) {
      return extract(parameters, regExpMatch);
    }
    return {};
  }

  RoutedInfo _createRoutedInfo() => RoutedInfo(
        context,
        url: widget.path,
        queryParams: Uri.tryParse(widget.path)?.queryParameters ?? {},
        pathParams: {},
        matchingRoute: '',
      );

  @override
  Widget build(BuildContext context) {
    // Create an initial info object, after we routed, inject it with a additional params
    final info = _createRoutedInfo();
    final routed = findRoutedWidget(widget.path, info);
    // TODO: The path contains url params, we want to strip them when doing matching
    if (routed != null) {
      info.matchingRoute = routed.resolveFullRoute(context);
      info.pathParams = _extractPathParams(routed.resolveFullRoute(context), widget.path, prefix: routed.prefix);
    }
    // Call the widget builder, it can access the updated info object
    Widget? child = routed?.builder();
    // If child is null, fallback to unknownRouteBuilder or a default child
    child ??= widget.unknownRouteBuilder?.call(context);
    child ??= DefaultUnknownRoute();
    // Provide the routed to the tree if we have one
    if (routed != null) child = _RoutedInfoProvider(info, child: child);
    // Use the built in switcher to handle state changes
    return AnimatedSwitcher(
      duration: widget.duration ?? const Duration(milliseconds: 350),
      child: child,
      transitionBuilder: widget.transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
    );
  }
}

class _RoutedInfoProvider extends InheritedWidget {
  _RoutedInfoProvider(this.value, {required Widget child}) : super(child: child);
  final RoutedInfo value;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => (oldWidget as _RoutedInfoProvider).value != value;
}

/// A path and associated widget builder.
class Routed {
  Routed(this.value, this.builder, {this.prefix = true});
  final String value;
  final bool prefix;
  final Widget Function() builder;

  Routed get exact => copyWith(prefix: false);

  String resolveFullRoute(BuildContext context) {
    if (value.startsWith('/')) return value; // Absolute path or wildcard
    String localPath = value;
    if (localPath == '*') localPath = localPath.substring(0, localPath.length - 1);
    String parentPath = '';
    RoutedInfo? info = RoutedInfo.of(context);
    if (info != null) parentPath = info.matchingRoute;
    return '$parentPath/$localPath';
  }

  Routed copyWith({String? value, bool? prefix, Widget Function()? builder}) {
    return Routed(value ?? this.value, builder ?? this.builder, prefix: prefix ?? this.prefix);
  }
}

/// Value object that is passed into the [PathSwitcher].builders delegate so pages can easily access values they need.
class RoutedInfo {
  RoutedInfo(
    this.context, {
    required this.url,
    required this.matchingRoute,
    required this.pathParams,
    required this.queryParams,
  });
  BuildContext? context;
  final String url;
  String matchingRoute;
  Map<String, String> pathParams;
  Map<String, String> queryParams;

  static RoutedInfo? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RoutedInfoProvider>()?.value;
}

class DefaultUnknownRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: Icon(Icons.error));
  }
}
