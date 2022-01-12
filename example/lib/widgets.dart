import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows instructions for the demo and the current location
class PageScaffoldWithInstructions extends StatelessWidget {
  final String location;

  const PageScaffoldWithInstructions(this.location, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
                'With your keyboard, press numbers 1-9 to change routes.\n\nNotice that the left-side menu changes as you navigate to various routes.'),
          ),
        ),
        Expanded(child: Center(child: Text(location)))
      ]),
    ));
  }
}

/// A scaffold meant to contain entire apps so we can test multiple router implementations quickly.
class MultiAppTestRig extends StatefulWidget {
  const MultiAppTestRig({Key? key, required this.tests}) : super(key: key);
  final List<WidgetBuilder> tests;

  @override
  State<MultiAppTestRig> createState() => _MultiAppTestRigState();
}

class _MultiAppTestRigState extends State<MultiAppTestRig> with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: widget.tests.length, vsync: this)
    ..addListener(() {
      // ignore: invalid_use_of_visible_for_testing_member
      setState(() {});
    });
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Column(children: [
          Expanded(
            child: widget.tests[_tabs.index].call(context),
          ),
          TabBar(
              controller: _tabs,
              tabs: ['GoRouter', 'VRouter', 'RouteMaster', 'Beamer'].map((e) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(e, style: TextStyle(color: Colors.black)),
                );
              }).toList())
        ]),
      ),
    );
  }
}

/// Wires up a child widget to the `keyboardMappings` and calling the setLocation callback
/// Allows various Router implementations to tie into the example more easily
class KeyboardTestHarness extends StatelessWidget {
  const KeyboardTestHarness({Key? key, required this.child, required this.setLocation}) : super(key: key);

  /// The demo is driven by keyboard listeners that allow you to quickly switch locations.
  static Map<LogicalKeyboardKey, String> get mappings => {
        LogicalKeyboardKey.digit1: '/',
        LogicalKeyboardKey.digit2: '/pageA',
        LogicalKeyboardKey.digit3: '/pageB',
        LogicalKeyboardKey.digit4: '/dashboard',
        LogicalKeyboardKey.digit5: '/dashboard/foo',
        LogicalKeyboardKey.digit6: '/dashboard/bar',
        LogicalKeyboardKey.digit7: '/settings',
        LogicalKeyboardKey.digit8: '/settings/foo',
        LogicalKeyboardKey.digit9: '/settings/bar',
      };

  final Widget child;
  final void Function(String location) setLocation;
  @override
  Widget build(BuildContext context) {
    final bindings = mappings.map((key, value) {
      return MapEntry(SingleActivator(key), () => setLocation(value));
    });
    return Focus(
      autofocus: true,
      child: CallbackShortcuts(bindings: bindings, child: child),
    );
  }
}

/// Stub
class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.red,
        child: const Center(
          child: Text('MAIN MENU'),
        ),
      );
}

/// Stub
class DashboardMenu extends StatelessWidget {
  const DashboardMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.blue,
        child: const Center(
          child: Text('DASHBOARD\nMENU'),
        ),
      );
}

/// Stub
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.green,
        child: const Center(
          child: Text('SETTINGS MENU'),
        ),
      );
}
