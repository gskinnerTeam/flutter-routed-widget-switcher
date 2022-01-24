import 'package:beamer/beamer.dart';
import 'package:example/main.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';

class BeamerApp extends StatefulWidget {
  @override
  State<BeamerApp> createState() => BeamerAppState();
}

class BeamerAppState extends State<BeamerApp> {
  late final routerDelegate = BeamerDelegate(
    initialPath: '/',
    locationBuilder: RoutesLocationBuilder(
      builder: (_, child) {
        // Wrap the navigator in a simple scaffold, with a persistent `SideBar` on the left
        return Row(
          children: [
            const SideBar(),
            Expanded(child: child),
          ],
        );
      },
      routes: {
        '/dashboard/*': _buildEmptyBeamer,
        '/settings/*': _buildEmptyBeamer,
        '/*': _buildEmptyBeamer,
        '/': _buildEmptyBeamer,
      },
    ),
  );

  _buildEmptyBeamer(context, state, data) {
    return Beamer(
      routerDelegate: BeamerDelegate(
          notFoundPage: BeamPage(child: PageScaffoldWithInstructions(state.uri.matchingRoute)),
          locationBuilder: RoutesLocationBuilder(
            routes: {},
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardTestHarness(
      setLocation: (value) => routerDelegate.beamToNamed(value),
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: routerDelegate,
      ),
    );
  }
}
