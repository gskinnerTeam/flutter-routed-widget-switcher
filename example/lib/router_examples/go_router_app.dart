import 'package:example/main.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterApp extends StatefulWidget {
  @override
  State<GoRouterApp> createState() => _GoRouterAppState();
}

class _GoRouterAppState extends State<GoRouterApp> {
  late GoRouter goRouter = GoRouter(
    navigatorBuilder: (_, state, navigator) {
      // Wrap the navigator in a simple scaffold, with a persistent `SideBar` on the left
      return Row(children: [
        const SideBar(),
        Expanded(child: navigator),
      ]);
    },
    // Use the error builder to show the current route, rather than implementing all the matches by hand
    errorBuilder: (_, state) => PageScaffoldWithInstructions(state.location, key: ValueKey(state.location)),
    routes: [],
  );

  @override
  Widget build(BuildContext context) => KeyboardTestHarness(
        setLocation: (value) => goRouter.go(value),
        child: MaterialApp.router(
          routeInformationParser: goRouter.routeInformationParser,
          routerDelegate: goRouter.routerDelegate,
        ),
      );
}
