import 'package:example/main.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

class VRouterApp extends StatefulWidget {
  @override
  State<VRouterApp> createState() => _VRouterAppState();
}

class _VRouterAppState extends State<VRouterApp> {
  final GlobalKey<VRouterState> _vRouterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return KeyboardTestHarness(
      setLocation: (value) => _vRouterKey.currentState?.to(value),
      child: VRouter(
          key: _vRouterKey,
          builder: (_, navigator) {
            // Wrap the navigator in a simple scaffold, with a persistent `SideBar` on the left
            return Row(
              children: [
                const SideBar(),
                Expanded(child: navigator),
              ],
            );
          },
          routes: [
            VWidget.builder(
              path: '*',
              builder: (_, data) => PageScaffoldWithInstructions(data.url ?? ''),
            ),
          ]),
    );
  }
}
