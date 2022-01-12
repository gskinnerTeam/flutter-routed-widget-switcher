import 'package:example/main.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class RouteMasterApp extends StatefulWidget {
  RouteMasterApp({Key? key}) : super(key: key);

  @override
  State<RouteMasterApp> createState() => RouteMasterAppState();
}

class RouteMasterAppState extends State<RouteMasterApp> {
  late final delegate = RoutemasterDelegate(routesBuilder: (_) {
    // Create a bunch of routes, matching the paths defined in keyboardMappings
    // Doing it this way because I can't figure out how to properly wrap a scaffold when using RouteMap.onUnknownRoute
    final paths = KeyboardTestHarness.mappings.values.toList()..remove('/');
    Map<String, PageBuilder> routes = {};
    for (var p in paths) {
      routes[p] = (_) => MaterialPage(key: ValueKey(p), child: PageScaffoldWithInstructions(p));
    }
    // Use a the `TabPage` and `PageStackNavigator` widgets provided by routermaster to wrap to the routes in some scaffolding
    routes['/'] = (_) => TabPage(
          paths: paths,
          child: Builder(
            // Wrap child with a Builder so we can access the `TabPage` state
            builder: (c) {
              final tabPage = TabPage.of(c);
              // Using the `TabPage`, build a `TabBarView` which internally holds the `Navigator`
              Widget content = TabBarView(
                controller: tabPage.controller,
                children: tabPage.stacks.map((s) => PageStackNavigator(stack: s)).toList(),
              );
              // Wrap the navigator in a simple scaffold, with a persistent `SideBar` on the left
              return Row(
                children: [
                  const SideBar(),
                  Expanded(child: content),
                ],
              );
            },
          ),
        );
    return RouteMap(routes: routes);
  });

  @override
  Widget build(BuildContext context) => KeyboardTestHarness(
        setLocation: (value) => delegate.push(value),
        child: MaterialApp.router(
          routeInformationParser: const RoutemasterParser(),
          routerDelegate: delegate,
        ),
      );
}
