import 'dart:async';

import 'action.dart';
import 'store.dart';

/// [StoreChange] is the payload for the [Store] subscription
class StoreChange<State, P> {
  final State next;
  final State prev;
  final Action<P> action;

  StoreChange(State n, State p, Action<P> a)
      : next = n,
        prev = p,
        action = a;
}

/// [StoreChangeHandler] handles a change the store after an action of type Action<T>
typedef StoreChangeHandler<P, State> = void Function(
  StoreChange<State, P> storeChange,
);

/// [StoreChangeHandlerBuilder] allows you to listen to the [Store] and perform handlers for a given
/// set of actions with many different payload types, while maintaining type safety.
/// Each [StoreChangeHandler] added with add<T> must take a [StoreChange] with prev and next of type
/// <State, StateBuilder> an Action of typ Action<T>,
class StoreChangeHandlerBuilder<State, Actions extends ReduxActions> {
  final _map = Map<String, StoreChangeHandler<dynamic, State>>();
  late StreamSubscription<StoreChange<State, dynamic>> _subscription;

  /// Registers [handler] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      StoreChangeHandler<Payload, State> handler) {
    _map[actionName.name] = (change) {
      handler(StoreChange<State, Payload>(
        change.next,
        change.prev,
        change.action as Action<Payload>,
      ));
    };
  }

  /// [build] sets up a subscription to the registered actions
  void build(Store<State, Actions> store) {
    _subscription =
        store.stream.listen((StoreChange<State, dynamic> storeChange) {
      var handler = _map[storeChange.action.name];
      if (handler != null) handler(storeChange);
    });
  }

  /// [dispose] cancels the subscription to the store
  void dispose() {
    _subscription.cancel();
  }
}
