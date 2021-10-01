/// True if the dynamic value is not null
bool isNotNull(dynamic value) {
  return value != null;
}

/// True if the provided string value is not null and is not empty (white spaces)
bool isNotBlank(String value) {
  return isNotNull(value) && value.trim().isNotEmpty;
}

/// Casts the `x` to the specified type `T`.
/// Null if `x` is not an instance of `T`
T cast<T>(x) => x is T ? x : null;
