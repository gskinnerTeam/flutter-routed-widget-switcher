import 'package:example/main.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

class UrlRouterApp extends StatefulWidget {
  @override
  State<UrlRouterApp> createState() => UrlRouterAppState();
}

class UrlRouterAppState extends State<UrlRouterApp> {
  final urlRouter = UrlRouter(
    builder: (_, navigator) {
      // Wrap the navigator in a simple scaffold, with a persistent `SideBar` on the left
      return Row(
        children: [
          const SideBar(),
          Expanded(child: navigator),
        ],
      );
    },
    onGeneratePages: (router) => [
      MaterialPage(child: PageScaffoldWithInstructions(router.url)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return KeyboardTestHarness(
      setLocation: (value) => urlRouter.url = value,
      child: MaterialApp.router(routerDelegate: urlRouter, routeInformationParser: UrlRouteParser()),
    );
  }
}
