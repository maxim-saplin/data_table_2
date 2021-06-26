/// State of the data.
enum DataState {
  /// Used when data are ready to be displayed.
  done,

  /// Used when the data are not yet ready because they are being loaded.
  loading,

  /// Used when an error occured while loading the data.
  error,
}
