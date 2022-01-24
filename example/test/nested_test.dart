// TODO: Add tests with urlRouter, and really hammer the nesting to make sure it works as expected.
// Think of other ways we can more directly test the parent router setup...
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routed_widget_switcher/routed_widget_switcher.dart';
import 'package:url_router/url_router.dart';

void main() {
  testWidgets('general tests', (tester) async {
    late UrlRouter urlRouter;
    Future<void> pumpUrlBuilderApp(List<Page> Function() pages) async {
      urlRouter = UrlRouter(onGeneratePages: (router) => pages());
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: UrlRouteParser(),
          routerDelegate: urlRouter,
        ),
      );
    }

    print('Basic path changing');
    await pumpUrlBuilderApp(() => [MaterialPage(child: Text(urlRouter.url))]);
    await tester.pumpAndSettle();
    expect(find.text('/'), findsOneWidget);
    urlRouter.url = '/1';
    await tester.pumpAndSettle();
    expect(find.text('/1'), findsOneWidget);

    print('Basic widget switching');
    await pumpUrlBuilderApp(() => [
          MaterialPage(
            child: RoutedSwitcher(
              builders: (info) => [
                Routed('/a', Placeholder.new),
                Routed('/b', FlutterLogo.new),
              ],
            ),
          )
        ]);

    urlRouter.url = '/a';
    await tester.pumpAndSettle();
    expect(find.byType(Placeholder), findsOneWidget);
    urlRouter.url = '/b';
    await tester.pumpAndSettle();
    expect(find.byType(FlutterLogo), findsOneWidget);

    print('Advanced widget switching');
    await pumpUrlBuilderApp(() => [
          MaterialPage(
            child: RoutedSwitcher(
              builders: (info) => [
                Routed('/a', () {
                  return RoutedSwitcher(
                    builders: (_) => [
                      Routed('1', () => Text('a1')),
                      Routed('2', () {
                        return RoutedSwitcher(
                          builders: (RoutedInfo info) {
                            return [
                              Routed('', () => Text('index')).exact,
                              Routed('*', () => Text('wildcard')),
                            ];
                          },
                        );
                      }),
                      Routed('/a/absolute', () => Text('absolute')),
                    ],
                  );
                }),
              ],
            ),
          )
        ]);
    // test relative
    urlRouter.url = '/a/1';
    await tester.pumpAndSettle();
    expect(find.text('a1'), findsOneWidget);
    // test absolute
    urlRouter.url = '/a/absolute';
    await tester.pumpAndSettle();
    expect(find.text('absolute'), findsOneWidget);
    // test absolute with params
    urlRouter.url = '/a/absolute?a=1';
    await tester.pumpAndSettle();
    expect(find.text('absolute'), findsOneWidget);
    // test index
    urlRouter.url = '/a/2';
    await tester.pumpAndSettle();
    expect(find.text('index'), findsNothing);

    urlRouter.url = '/a/2/';
    await tester.pumpAndSettle();
    expect(find.text('index'), findsOneWidget);

    // test index w/ query params
    urlRouter.url = '/a/2?a=1';
    await tester.pumpAndSettle();
    expect(find.text('index'), findsNothing);

    urlRouter.url = '/a/2/?a=1';
    await tester.pumpAndSettle();
    expect(find.text('index'), findsOneWidget);

    // test wildcard
    urlRouter.url = '/a/2/foo';
    await tester.pumpAndSettle();
    expect(find.text('wildcard'), findsOneWidget);
    //
    // test wildcard w/ query params
    urlRouter.url = '/a/2/404?a=1';
    await tester.pumpAndSettle();
    expect(find.text('wildcard'), findsOneWidget);

    print('Most specific match tests');
    await pumpUrlBuilderApp(() => [
          MaterialPage(child: RoutedSwitcher(
            builders: (RoutedInfo info) {
              return [
                Routed('*', DefaultUnknownRoute.new),
                Routed('/team/new', () => Text('New Team')),
                Routed('/team/:id', () => Text('${info.pathParams['id']}')),
              ];
            },
          ))
        ]);

    urlRouter.url = '/team/new';
    await tester.pumpAndSettle();
    expect(find.text('New Team'), findsOneWidget);
  });
}
