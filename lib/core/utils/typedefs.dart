
/// Define a Function that return a bool and accept a single argument of type T.
typedef Predicate<T> = bool Function(T value);

/// Define a Function that return void and accept a single argument of type T.
typedef VoidCallback<T> = void Function(T value);
