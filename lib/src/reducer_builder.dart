import 'package:built_collection/built_collection.dart';

import 'action.dart';
import 'typedefs.dart';

/// [ReducerBuilder] allows you to build a reducer that handles many different actions
/// with many different payload types, while maintaining type safety.
/// Each [Reducer] added with add<T> must take a state of type State, an Action of type
/// Action<T>, and a builder of type B.
/// Nested reducers can be added with [combineNested]
class ReducerBuilder<State> {
  final _map = Map<String, Reducer<State, dynamic>>();

  ReducerBuilder();

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(
      ActionName<Payload> actionName, Reducer<State, Payload> reducer) {
    _map[actionName.name] = (state, action) {
      return reducer(state, action as Action<Payload>);
    };
  }

  /// [combine] combines this ReducerBuilder with another ReducerBuilder
  /// for the same type
  void combine(ReducerBuilder<State> other) {
    _map.addAll(other._map);
  }

  /// [combineNested] combines this ReducerBuilder with a NestedReducerBuilder
  @pragma('dart2js:noInline')
  void combineNested<N>(NestedReducerBuilder<State, N> nested) {
    _map.addAll(nested._map);
  }

  /// [combineAbstract] combines this ReducerBuilder with an AbstractReducerBuilder.
  /// This function takes the result of AbstractReducerBuilder's .build() function,
  /// which is a map. It does not take an AbstractReducerBuilder directly.
  void combineAbstract(Map<String, Reducer<State, dynamic>> other) {
    _map.addAll(other);
  }

  /// [combineList] combines this ReducerBuilder with a ListReducerBuilder
  void combineList<T>(ListReducerBuilder<State, T> other) {
    _map.addAll(other._map);
  }

  /// [combineListMultimap] combines this ReducerBuilder with a ListMultimapReducerBuilder
  void combineListMultimap<K, V>(
      ListMultimapReducerBuilder<State, K, V> other) {
    _map.addAll(other._map);
  }

  /// [combineMap] combines this ReducerBuilder with a MapReducerBuilder
  void combineMap<K, V>(MapReducerBuilder<State, K, V> other) {
    _map.addAll(other._map);
  }

  /// [combineSet] combines this ReducerBuilder with a SetReducerBuilder
  void combineSet<T>(SetReducerBuilder<State, T> other) {
    _map.addAll(other._map);
  }

  /// [combineSetMultimap] combines this ReducerBuilder with a SetMultimapReducerBuilder
  void combineSetMultimap<K, V>(SetMultimapReducerBuilder<State, K, V> other) {
    _map.addAll(other._map);
  }

  /// [build] returns a reducer function that can be passed to a [Store].
  Reducer<State, dynamic> build() => (State state, Action<dynamic> action) {
        final reducer = _map[action.name];
        if (reducer != null) {
          return reducer(state, action);
        } else {
          return state;
        }
      };
}

/// [Mapper] is a function that takes an object and maps it to another object.
/// Used for state and builder mappers passed to [NestedReducerBuilder].
typedef Mapper<State, NestedState> = NestedState Function(State state);

/// [NestedReducerBuilder] allows you to build a reducer that rebuilds built values
/// nested within your main app state model. For example, consider the following built value
///
/// ```dart
/// abstract class BaseState implements Built<BaseState, BaseStateBuilder> {
///
///  NestedBuiltValue get nestedBuiltValue;
///
///  // Built value constructor
///  BaseState._();
///  factory BaseState() => new _$BaseState._(
///        count: 1,
///        nestedBuiltValue: new NestedBuiltValue(),
///      );
/// }
/// ```
/// A NestedReducerBuilder can be used to map certain actions to reducer
/// functions that only rebuild nestedBuiltValue
///
/// Two mapper functions are required by the constructor to map the state and state builder objects
/// to the nested value and nested builder.
///
/// [_stateMapper] maps the state built to the nested built, in this case:
/// ```dart
///   (BaseCounter state) => state.nestedBuiltValue
/// ```
///
/// [_builderMapper] maps the state builder to the nested builder, in this case:
/// ```dart
///   (BaseCounterBuilder stateBuilder) => stateBuilder.nestedBuiltValue
/// ```
///
class NestedReducerBuilder<State, NestedState> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, NestedState> _stateMapper;

  NestedReducerBuilder(
    this._stateMapper,
  );

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      NestedReducer<State, NestedState, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          state,
          _stateMapper(state),
          action as Action<Payload>,
        );
  }

  /// [combineReducerBuilder] takes a `ReducerBuilder` with the type arguments
  /// `NestedState`, `NestedStateBuilder`, and combines it with this `NestedReducerBuilder`.
  void combineReducerBuilder(ReducerBuilder<State> other) {
    _map.addAll(other._map);
  }
}

/// [AbstractReducerBuilder] returns a reducer builder that
/// rebuilds an abstract, or mixed in, piece of state. For most cases
/// AbstractReducerBuilder is not recommended. When defining your state
/// model favor composition over inheritance. However, this may be
/// useful when trying to share functionaity between two separate redux stores.
class AbstractReducerBuilder<AState, BState> {
  final _map = Map<String, CReducer<AState, BState, dynamic>>();

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<AState, BState, Payload> reducer) {
    _map[actionName.name] = (state, action) {
      return reducer(state, action as Action<Payload>);
    };
  }

  Map<String, CReducer<AState, BState, dynamic>> build() => _map;
}

/// This is the Reducer typedef without the Built/Builder constraints
/// Used for built_collections since they do not implement Built/Builder
/// but follow the same pattern.
typedef CReducer<AState, BState, P> = BState Function(
    AState state, Action<P> action);

/// [ListReducerBuilder] returns a reducer builder that
/// rebuilds a List nested within the state tree
class ListReducerBuilder<State, T> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, BuiltList<T>> _stateMapper;

  ListReducerBuilder(this._stateMapper);

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<BuiltList<T>, State, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          _stateMapper(state),
          action as Action<Payload>,
        );
  }
}

/// [ListMultimapReducerBuilder] returns a reducer builder that
/// rebuilds a ListMultimap nested within the state tree
class ListMultimapReducerBuilder<State, K, V> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, BuiltListMultimap<K, V>> _stateMapper;

  ListMultimapReducerBuilder(this._stateMapper);

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<BuiltListMultimap<K, V>, State, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          _stateMapper(state),
          action as Action<Payload>,
        );
  }
}

/// [MapReducerBuilder] returns a reducer builder that
/// rebuilds a Map nested within the state tree
class MapReducerBuilder<State, K, V> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, BuiltMap<K, V>> _stateMapper;

  MapReducerBuilder(this._stateMapper);

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<BuiltMap<K, V>, State, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          _stateMapper(state),
          action as Action<Payload>,
        );
  }
}

/// [SetReducerBuilder] returns a reducer builder that
/// rebuilds a Set nested within the state tree
class SetReducerBuilder<State, T> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, BuiltSet<T>> _stateMapper;

  SetReducerBuilder(this._stateMapper);

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<BuiltSet<T>, State, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          _stateMapper(state),
          action as Action<Payload>,
        );
  }
}

/// [SetMultimapReducerBuilder] returns a reducer builder that
/// rebuilds a SetMultimap nested within the state tree
class SetMultimapReducerBuilder<State, K, V> {
  final _map = Map<String, Reducer<State, dynamic>>();
  Mapper<State, BuiltSetMultimap<K, V>> _stateMapper;

  SetMultimapReducerBuilder(this._stateMapper);

  /// Registers [reducer] function to the given [actionName]
  void add<Payload>(ActionName<Payload> actionName,
      CReducer<BuiltSetMultimap<K, V>, State, Payload> reducer) {
    _map[actionName.name] = (state, action) => reducer(
          _stateMapper(state),
          action as Action<Payload>,
        );
  }
}
