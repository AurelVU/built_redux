import 'dart:async';

/// [Action] is the object passed to your reducer to signify the state change that needs to take place.
/// Action [name]s should always be unique. Uniqeness is guarenteed when using ReduxActions.
class Action<Payload, Result> {
  /// A unique action name.
  final String name;

  /// The actions payload.
  final Payload payload;

  final Completer<Result>? completer;

  // factory Action(name, payload) => NullableAction(name, payload);
  Action(this.name, this.payload, [this.completer]);

  @override
  String toString() => 'Action {\n  name: $name,\n  payload: $payload,\n}';
}

typedef EmptyAction<Payload> = Action<Payload, void>;

// Dispatches an action to the store
typedef Dispatcher<P, R> = void Function(Action<P, R> action);

/// [ActionDispatcher] dispatches an action with the name provided
/// to the constructor and the payload supplied when called. You will notice
/// [ActionDispatcher] is an object, however it is to be used like a function.
/// In the following example increment is an action dispatcher, that when called
/// dispatches an action to the redux store with the name increment and the payload 3.
///
/// ```dart
/// store.actions.increment(3);
/// ```
class ActionDispatcher<P, R> {
  late Dispatcher _dispatcher;
  final String _name;

  String get name => _name;

  Completer<R> call(P payload, {Completer<R>? completer}) {
    final workedCompleter = completer ?? Completer<R>();
    _dispatcher(Action<P, R>(_name, payload, workedCompleter));
    return workedCompleter;
  }

  ActionDispatcher(this._name);

  void setDispatcher(Dispatcher dispatcher) {
    _dispatcher = dispatcher;
  }
}

typedef EmptyActionDispatcher<P> = ActionDispatcher<P, void>;

/// [ReduxActions] is a container for all of your applications actions.
///
/// When using [ReduxActions] the developer does not have to instantiate their [ActionDispatcher]s,
/// they only need to define them.
///
/// The generator will generate a class with all of the boilerplate need to instantiate the
/// [ActionDispatcher]s and sync them with the redux action dispatcher.
///
/// The generator will also generate another class, [ActionNames], that contains
/// a static accessors for each [ActionDispatcher] that is typed with a generic that is the same
/// as the [ActionDispatcher] payload generic. This allows you to build reducer handlers with type
/// safety without having to instantiate your instance of [ReduxActions].
///
/// One can also nest [ReduxActions] just like one can nest built_values.
///
///  Example:
///
///  The following actions
///
///  ```dart
///  abstract class BaseActions {
///   ActionDispatcher<int> foo;
///   NestedActions nestedActions;
///  }
///
///  abstract class NestedActions {
///   ActionDispatcher<int> bar;
///  }
///  ```
///
///  generate to
///
///  ```dart
///  class _$BaseActions extends BaseActions {
///   final ActionDispatcher<int> foo = ActionDispatcher<int>('BaseActions-foo');
///   final NestedActions nestedActions = NestedActions();
///
///   factory _$BaseActions() => _$BaseActions._();
///   _$BaseActions._() : super._();
///
///   setDispatcher(dispatcher) {
///     foo.setDispatcher(dispatcher);
///     nestedActions.setDispatcher(dispatcher);
///   }
/// }
///
///  class BaseActionsNames {
///   static ActionName foo = ActionName<int>('BaseActions-foo');
/// }
///
/// class _$NestedActions extends NestedActions {
///   final ActionDispatcher<int> bar = ActionDispatcher<int>('NestedActions-bar');
///
///   factory _$NestedActions() => _$NestedActions._();
///   _$NestedActions._() : super._();
///
///   setDispatcher(dispatcher) {
///     bar.setDispatcher(dispatcher);
///   }
/// }
///
///  class NestedActionsNames {
///   static ActionName bar = ActionName<int>('NestedActions-bar');
/// }
/// ```
abstract class ReduxActions {
  void setDispatcher(Dispatcher dispatcher);
}

/// [ActionName] is an object that simply contains the action name but is typed with a generic that
/// is the same as the relative [ActionDispatcher]s payload generic. This allows you to declare reducer
/// handlers with safety without having to instantiate your instance of [ReduxActions].
class ActionName<T, R> {
  String name;
  ActionName(this.name);
}
