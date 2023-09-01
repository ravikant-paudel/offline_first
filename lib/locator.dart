// Copyright (c) 2020 The Khalti Authors. All rights reserved.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:offline_first/database/database.dart';

typedef NavigatorKeyCallback = GlobalKey<NavigatorState> Function();

class Locator {
  static final _isInit = Completer<void>();

  String? currentPage;

  bool isMainPageActive = false;

  @visibleForTesting
  static bool isTest = false;

  /// Lazy singleton to locate all the dependencies.
  Locator() {
    // if (KhaltiLocator.instance.isNull) KhaltiLocator.init(Locator._());
    // return KhaltiLocator.getInstance();
  }


  /// If app is in minimized or terminated state
  static bool _isBackground = false;

  Locator._() {
    if (!isTest) _init();
  }

  /// Await locator so that it can complete initialization.
  static Future<void> init({bool isBackground = false}) async {
    _isBackground = isBackground;
    Locator();
    if (isTest) return;
    return _isInit.future;
  }

  // ******************** Instantiate Locator ********************
  Future<void> _init() async {
    if (_isInit.isCompleted) return;

    // Packages Here
    await offlineDbase.init();
  }

  OfflineDatabase offlineDbase = OfflineDatabase();

}

Locator get locator => Locator();

