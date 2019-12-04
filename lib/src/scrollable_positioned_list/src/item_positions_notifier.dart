// Copyright 2019 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'item_positions_listener.dart';

/// Internal implementation of [ItemPositionsListener].
class ItemPositionsNotifier implements ItemPositionsListener {

  // tweak by eldorico.
  double _customMaxExtend = -1;

  @override
  double get customMaxExtend => _customMaxExtend;

  @override
  set customMaxExtend(double customMaxExtend) => _customMaxExtend = customMaxExtend;

  @override
  resetCustomMaxExtend() => _customMaxExtend = -1;

  @override
  final ValueNotifier<Iterable<ItemPosition>> itemPositions = ValueNotifier([]);
}
