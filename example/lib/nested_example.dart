import 'package:flutter/material.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';
import 'package:url_router/url_router.dart';

class NestedAppExample extends StatelessWidget {
  NestedAppExample({Key? key}) : super(key: key);

  final UrlRouter router = UrlRouter(
    onGeneratePages: (_) => [
      MaterialPage(
        child: RoutedSwitcher(
          builders: (info) => [
            //Routed('/', MainScreen.new),
            Routed('a', () {
              return RoutedSwitcher(
                builders: (_) => [
                  //Routed('profile', ProfileScreen.new),
                  Routed('2', () {
                    return RoutedSwitcher(
                      builders: (_) => [
                        Routed('', Placeholder.new).exact,
                        Routed('*', () => Text('wildcard')),
                        // Routed('alerts', AlertsScreen.new),
                        // Routed('reminders', RemindersScreen.new),
                      ],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: UrlRouteParser(),
      routerDelegate: router,
    );
    // return RoutedSwitcher(
    //   builders: (_) => [
    //     Routed(
    //       '/messages',
    //       () => RoutedSwitcher(
    //         builders: (_) => [
    //           Routed('inbox', Inbox.new),
    //           Routed('outbox', Outbox.new),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.red);
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.green);
}

class AlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.blue);
}

class RemindersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.pink);
}

class Inbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.pink);
}

class Outbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.pink);
}
