import 'package:beamer/beamer.dart';
import 'package:example/router_examples/beamer_app.dart';
import 'package:example/router_examples/go_router_app.dart';
import 'package:example/router_examples/routermaster_app.dart';
import 'package:example/router_examples/vrouter_app.dart';
import 'package:example/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vrouter/vrouter.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  testWidgets('VRouter', (WidgetTester tester) async {
    await tester.pumpWidget(VRouterApp());
    VRouterState router = tester.state(find.byType(VRouter));
    await runTest(tester, router.to);
  });

  testWidgets('GoRouter', (WidgetTester tester) async {
    await tester.pumpWidget(GoRouterApp());
    final nav = tester.state(find.byType(Navigator));
    await runTest(tester, nav.context.go);
  });

  testWidgets('Beamer', (WidgetTester tester) async {
    await tester.pumpWidget(BeamerApp());
    BeamerAppState beamer = tester.state(find.byType(BeamerApp));
    await runTest(tester, (s) => beamer.routerDelegate.beamToNamed(s));
  });

  testWidgets('Routemaster', (WidgetTester tester) async {
    await tester.pumpWidget(RouteMasterApp());
    RouteMasterAppState router = tester.state(find.byType(RouteMasterApp));
    await runTest(tester, (s) => router.delegate.push(s));
  });
}

Future<void> runTest(WidgetTester tester, void Function(String) go) async {
  // Should start on main menu
  expect(find.byType(MainMenu), findsOneWidget);
  // Navigate to dashboard, and expect to see the DashboardMenu
  go('/dashboard');
  await tester.pumpAndSettle();
  expect(find.byType(DashboardMenu), findsOneWidget);
  // Navigate to settings, and expect to see the SettingsMenu
  go('/settings');
  await tester.pumpAndSettle();
  expect(find.byType(SettingsMenu), findsOneWidget);
  // Navigate to pageA, and expect to see the MainMenu
  go('/pageA');
  await tester.pumpAndSettle();
  expect(find.byType(MainMenu), findsOneWidget);
}
