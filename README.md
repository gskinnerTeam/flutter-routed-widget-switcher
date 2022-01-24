<a href="https://github.com/gskinnerTeam/flutter-routed-widget-switcher/actions"><img src="https://github.com/gskinnerTeam/flutter-routed-widget-switcher/workflows/core-tests/badge.svg" alt="Build Status"></a>
<a href="https://github.com/gskinnerTeam/flutter-routed-widget-switcher/actions"><img src="https://github.com/gskinnerTeam/flutter-routed-widget-switcher/workflows/third-party-router-tests/badge.svg" alt="Build Status"></a>

## Features
Declaratively switch child widgets based on the current `Router` location.
```dart
class SideBar extends StatelessWidget {
    Widget build(_){
     return RoutedSwitcher(
        builders: (info) => [
            // All widgets are lazy loaded...
            Routed('/', () => MainMenu()), // use a closure
            Routed('/dashboard', DashboardMenu.new), // or a tear-off :)
        ]);
    }
}
```
Intended as a complimentary package for any `Router` (aka Nav2) implementation. Including popular routing solutions like [GoRouter](https://pub.dev/packages/go_router), [RouteMaster](https://pub.dev/packages/routemaster) or [VRouter](https://pub.dev/packages/vrouter).

This is useful in 2 primary use cases:
* when  you have scaffolding around your Navigator, like a `SideBar` or a `TitleBar` and you would like it to react to location changes
* when multiple paths resolve to the same `Page` and you want to move subsequent routing further down the tree

*Note:* This package does not provide any control of the routers location, it simply reads the current location and responds accordingly.


## 🔨 Installation
```yaml
dependencies:
  routed_widget_switcher: ^2.0.1
```


## 🕹️ Usage
Place the widget anywhere below the root `Router` widget and define the paths you would like to match. By default paths are considered to be case-insensitive, and treated as prefixes, but this can be disabled:
```dart
return RoutedSwitcher(
  caseSensitive: true,
  builders: (info) => [
    // use '.exact' to match only '/'
    Routed('/', MainMenu.new).exact,
     // match anything prefixed with `/dashboard`
    Routed('/dashboard', DashboardMenu.new),
    // use the info object to get path or query params
    Routed('/settings', () => SettingsMenu(type: info.queryParams['type'])),
  ],
);
```
The `builders` delegate passes a `RoutedInfo` object which contains info about the current match, including:
* url
* matchingRoute
* pathParams
* queryParams

You can also call `RoutedInfo.of(context)` from any descendant widgets to lookup the closest instance.

#### Unknown routes
Use the `unknownRouteBuilder` to handle unexpected routes. If the delegate is not provided, a `DefaultUnknownRoute` widget will be used.

## Path matching
Paths can be defined as simple strings like `/user/new` or `user/:userId`, or use regular expression syntax like `r'/user/:id(\d+)'`. See `pathToRegExp` library for more details on advanced use cases: https://pub.dev/packages/path_to_regexp.

In addition to the matching performed by `pathToRegExp`, a wildcard `*` character can be used to match any location.

### Most specific match
`RoutedSwitcher` will attempt to use the most specific match. For example,the location of `/users/new` matches all three of these builders:
```dart
Routed('/users/:userId', TeamDetails.new),
Routed('/users/new', NewTeamForm.new),
Routed('*', TeamStandings.new),
```
Since `/users/new` is the more exact match, it will be the one to render, it does not matter which order you declare them in. `/users/:userId` would go next, with the wildcard `*` finally matching last.


### Transitions
Internally Flutters `AnimatedSwitcher` widget is used for transitions, so that full API is exposed for different transition effects.
```dart
return RoutedSwitcher(
  transitionBuilder: ...
  duration: ...,
  builders: ...,
)
```

### Relative links and inheritance
Nested switchers are supported to any depth, and relative paths can be defined by omitting the `/` character.
```dart
return RoutedSwitcher(
  builders: (_) => [
    Routed(
      '/messages',
      () => RoutedSwitcher(
        builders: (_) => [
          Routed('', Inbox.new), // -> /messages/
          Routed('inbox', Inbox.new), // -> /messages/inbox
          Routed('outbox', Outbox.new), // -> /messages/outbox
        ],
      ),
    ),
  ],
);
```



 ## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
