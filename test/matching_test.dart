import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';

void main() {
  group('getMostSpecificMatch', () {
    testWidgets('general tests', (tester) async {
      var switcher = PathWidgetSwitcher(
        location: '/',
        builders: [
          PathBuilder('*', builder: (_) => Container()),
          PathBuilder('/', builder: (_) => Container()),
          PathBuilder(r'/account/:id(\d+)', builder: (_) => Container()),
          PathBuilder('/user/:id', builder: (_) => Container()),
          PathBuilder('/user/create', builder: (_) => Container()),
          PathBuilder('/p', builder: (_) => Container()),
        ],
      );

      /// '/account/foo' should not match the accounts path since it is non-numeric
      /// we'd expect it to match '/' instead
      var match = switcher.findRoutedWidget('/account/foo');
      expect(match!.path, '/');

      /// '/account/99' should match the accounts path since it's numeric
      match = switcher.findRoutedWidget('/account/99');
      expect(match!.path, r'/account/:id(\d+)');

      /// '/user/create' matches multiple paths, but the more specific one should be chosen
      match = switcher.findRoutedWidget('/user/create');
      expect(match!.path, '/user/create');

      /// '/user/99' matches multiple paths, but `/user/:id` should be most specific
      match = switcher.findRoutedWidget('/user/99');
      expect(match!.path, '/user/:id');

      /// '/nomatch' should match the '/' prefix
      match = switcher.findRoutedWidget('/nomatch');
      expect(match!.path, '/');

      /// '/p' should match the '/p' over the '/' prefix
      match = switcher.findRoutedWidget('/p');
      expect(match!.path, '/p');

      /// 'nomatch' should match wildcard because it doesn't have a '/' prefix
      match = switcher.findRoutedWidget('nomatch');
      expect(match!.path, '*');
    });

    testWidgets('prefixes', (tester) async {
      final switcher = PathWidgetSwitcher(
        location: '/',
        builders: [
          PathBuilder('/', builder: (_) => Container()),
        ],
      );

      /// '/anything' should match
      var match = switcher.findRoutedWidget('/anything');
      expect(match!.path, '/');

      /// '/' should match
      match = switcher.findRoutedWidget('/');
      expect(match!.path, '/');

      /// 'nomatch' should not match anything as there is no wildcard
      match = switcher.findRoutedWidget('nomatch');
      expect(match, null);
    });

    testWidgets('non-prefixed and case sensitive', (tester) async {
      // A router that requires an exact match on '/'
      var switcher = PathWidgetSwitcher(
        location: '/',
        builders: [
          PathBuilder('/', prefix: false, builder: (_) => Container()),
          PathBuilder('/test', builder: (_) => Container()),
        ],
      );

      /// '/anything' should NOT match, since prefix=false
      var match = switcher.findRoutedWidget('/anything');
      expect(match, null);

      /// '/' should match
      match = switcher.findRoutedWidget('/');
      expect(match!.path, '/');

      /// '/TEST' should match since this is not case sensitive
      match = switcher.findRoutedWidget('/TEST');
      expect(match!.path, '/test');

      /// Create a switcher that is case sensistive at the top, but overridden by a widget below.
      switcher = PathWidgetSwitcher(
        location: '/',
        caseSensitive: true,
        builders: [
          PathBuilder('/test', builder: (_) => Container()),
          PathBuilder('/override', caseSensitive: false, builder: (_) => Container()),
        ],
      );

      /// '/TEST' should NOT match since this IS case sensitive
      match = switcher.findRoutedWidget('/TEST');
      expect(match, null);

      /// '/test' should match
      match = switcher.findRoutedWidget('/test');
      expect(match!.path, '/test');

      /// '/OVERRIDE' should match since it manually sets caseSensitive to false
      match = switcher.findRoutedWidget('/OVERRIDE');
      expect(match!.path, '/override');
    });
  });
}
