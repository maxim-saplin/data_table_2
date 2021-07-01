// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2021 Kristián Balaj - changes and modifications to original Flutter implementation of DataTable

/// State of the data.
enum DataState {
  /// Used when data are ready to be displayed.
  done,

  /// Used when the data are not yet ready because they are being loaded.
  loading,

  /// Used when an error occured while loading the data.
  error,
}
