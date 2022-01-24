import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';

GlobalKey<PathSwitcherState>? switcherKey;
PathSwitcherState get switcher => switcherKey!.currentState!;

void main() {
  PathSwitcher buildSwitcher(
      {required String path, required List<Routed> Function(RoutedInfo info) builders, bool caseSensitive = false}) {
    switcherKey = GlobalKey<PathSwitcherState>();
    return PathSwitcher(key: switcherKey, path: path, builders: builders, caseSensitive: caseSensitive);
  }

  RoutedInfo? info;
  Future<void> pumpNestedApp(WidgetTester tester, String path, {bool exact = false}) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: buildSwitcher(
                path: path,
                builders: (_) => [
                      Routed('a', () {
                        return PathSwitcher(
                            path: path,
                            builders: (i) {
                              info = i;
                              return [
                                Routed(':id', () {
                                  return PathSwitcher(
                                      path: path,
                                      builders: (i) {
                                        info = i;
                                        return [
                                          Routed('c', () => Text('c'), prefix: !exact),
                                        ];
                                      });
                                })
                              ];
                            });
                      })
                    ]))));
  }

  /// Test multiple relative urls
  testWidgets('nested', (tester) async {
    void testNestedRoutes(String expectedText) {
      expect(find.text(expectedText), findsOneWidget);
      expect(info?.queryParams, {'a': '1'});
      expect(info?.pathParams, {'id': '99'});
      expect(info?.pathParams != {'id': '1'}, true);
    }

    await pumpNestedApp(tester, '/');
    expect(find.text('c'), findsNothing);

    await pumpNestedApp(tester, '/a/99/c?a=1');
    testNestedRoutes('c');

    await pumpNestedApp(tester, '/a/99/c/?a=1');
    testNestedRoutes('c');

    await pumpNestedApp(tester, '/a/99/c/?a=1', exact: true);
    expect(find.byType(DefaultUnknownRoute), findsOneWidget);
  });

  testWidgets('general tests', (tester) async {
    await tester.pumpWidget(buildSwitcher(
        path: '/',
        builders: (_) => [
              Routed('*', Container.new),
              Routed('/', Container.new),
              Routed(r'/account/:id(\d+)', Container.new),
              Routed('/user/:id', Container.new),
              Routed('/user/create', Container.new),
              Routed('/p', Container.new),
            ]));

    /// '/account/foo' should not match the accounts path since it is non-numeric
    /// we'd expect it to match '/' instead
    var match = switcher.findRoutedWidget('/account/foo');
    expect(match!.value, '/');

    /// '/account/99' should match the accounts path since it's numeric
    match = switcher.findRoutedWidget('/account/99');
    expect(match!.value, r'/account/:id(\d+)');

    /// '/user/create' matches multiple paths, but the more specific one should be chosen
    match = switcher.findRoutedWidget('/user/create');
    expect(match!.value, '/user/create');

    /// '/user/99' matches multiple paths, but `/user/:id` should be most specific
    match = switcher.findRoutedWidget('/user/99');
    expect(match!.value, '/user/:id');

    /// '/nomatch' should match the '/' prefix
    match = switcher.findRoutedWidget('/nomatch');
    expect(match!.value, '/');

    /// '/p' should match the '/p' over the '/' prefix
    match = switcher.findRoutedWidget('/p');
    expect(match!.value, '/p');

    /// 'nomatch' should match wildcard because it doesn't have a '/' prefix
    match = switcher.findRoutedWidget('nomatch');
    expect(match!.value, '*');
  });

  testWidgets('prefixes', (tester) async {
    await tester.pumpWidget(buildSwitcher(
      path: '/',
      builders: (_) => [
        Routed('/', Container.new),
      ],
    ));

    /// '/anything' should match
    var match = switcher.findRoutedWidget('/anything');
    expect(match!.value, '/');

    /// '/' should match
    match = switcher.findRoutedWidget('/');
    expect(match!.value, '/');

    /// 'nomatch' should not match anything as there is no wildcard
    match = switcher.findRoutedWidget('nomatch');
    expect(match, null);
  });

  testWidgets('non-prefixed and case sensitive', (tester) async {
    // A router that requires an exact match on '/'
    await tester.pumpWidget(buildSwitcher(
      path: '/',
      builders: (_) => [
        Routed('/', Container.new).exact,
        Routed('/test', Container.new),
      ],
    ));

    /// '/anything' should NOT match, since prefix=false
    var match = switcher.findRoutedWidget('/anything');
    print(match?.value);
    expect(match, null);

    /// '/' should match
    match = switcher.findRoutedWidget('/');
    expect(match!.value, '/');

    /// '/TEST' should match since this is not case sensitive
    match = switcher.findRoutedWidget('/TEST');
    expect(match!.value, '/test');

    /// Create a switcher that is case sensitive at the top, but overridden by a widget below.
    await tester.pumpWidget(buildSwitcher(
      path: '/',
      caseSensitive: true,
      builders: (_) => [
        Routed('/test', Container.new),
      ],
    ));

    /// '/TEST' should NOT match since this IS case sensitive
    match = switcher.findRoutedWidget('/TEST');
    expect(match, null);

    /// '/test' should match
    match = switcher.findRoutedWidget('/test');
    expect(match!.value, '/test');
  });
}
