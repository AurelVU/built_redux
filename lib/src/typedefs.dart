import 'action.dart';
import 'middleware.dart';

/// [Reducer] is a function that given a state of type V, an Action of type Action<P>, and a
/// builder of type B builds the next state
typedef Reducer<State, Payload> = void Function(
    State state, Action<Payload> action);

/// [ActionHandler] handles an action, this will contain the actual middleware logic
typedef ActionHandler = void Function(Action<dynamic> a);

/// [NextActionHandler] takes the next [ActionHandler] in the middleware chain and returns
/// an [ActionHandler] for the middleware
typedef NextActionHandler = ActionHandler Function(ActionHandler next);

/// [Middleware] is a function that given the store's [MiddlewareApi] returns a [NextActionHandler].
typedef Middleware<State, Actions extends ReduxActions> = NextActionHandler
    Function(MiddlewareApi<State, Actions> api);

/// [SubstateChange] is the payload for `StateChangeTransformer`'s stream. It contains
/// the previous and next value of the state resulting from the mapper provided to `StateChangeTransformer`
class SubstateChange<Substate> {
  Substate prev;
  Substate next;

  SubstateChange(this.prev, this.next);
}

/// [StateMapper] takes a state model and maps it to the values one cares about
typedef StateMapper<State, Substate> = Substate Function(State state);
