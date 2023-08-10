import 'dart:async';

import 'package:built_value/built_value.dart';

import 'action.dart';
import 'store.dart';

/// [StoreChange] is the payload for the [Store] subscription
class StoreChange<State extends Built<State, StateBuilder>,
    StateBuilder extends Builder<State, StateBuilder>, P, R extends Object?> {
  final State next;
  final State prev;
  final Action<P, R> action;

  StoreChange(State n, State p, Action<P, R> a)
      : next = n,
        prev = p,
        action = a;
}

/// [StoreChangeHandler] handles a change the store after an action of type Action<T, R>
typedef StoreChangeHandler<P, R extends Object?, State extends Built<State, StateBuilder>,
        StateBuilder extends Builder<State, StateBuilder>>
    = void Function(
  StoreChange<State, StateBuilder, P, R> storeChange,
);

/// [StoreChangeHandlerBuilder] allows you to listen to the [Store] and perform handlers for a given
/// set of actions with many different payload types, while maintaining type safety.
/// Each [StoreChangeHandler] added with add<T> must take a [StoreChange] with prev and next of type
/// <State, StateBuilder> an Action of typ Action<T, R>,
class StoreChangeHandlerBuilder<
    State extends Built<State, StateBuilder>,
    StateBuilder extends Builder<State, StateBuilder>,
    Actions extends ReduxActions> {
  final _map = Map<String, StoreChangeHandler<dynamic, dynamic, State, StateBuilder>>();
  late StreamSubscription<StoreChange<State, StateBuilder, dynamic, dynamic>>
      _subscription;

  /// Registers [handler] function to the given [actionName]
  void add<Payload, Result extends Object?>(ActionName<Payload, Result> actionName,
      StoreChangeHandler<Payload, Result, State, StateBuilder> handler) {
    _map[actionName.name] = (change) {
      handler(StoreChange<State, StateBuilder, Payload, Result>(
        change.next,
        change.prev,
        change.action as Action<Payload, Result>,
      ));
    };
  }

  /// [build] sets up a subscription to the registered actions
  void build(Store<State, StateBuilder, Actions> store) {
    _subscription = store.stream
        .listen((StoreChange<State, StateBuilder, dynamic, dynamic> storeChange) {
      var handler = _map[storeChange.action.name];
      if (handler != null) handler(storeChange);
    });
  }

  /// [dispose] cancels the subscription to the store
  void dispose() {
    _subscription.cancel();
  }
}
