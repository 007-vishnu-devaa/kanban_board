// coverage:ignore-file
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final controller = StreamController<bool>();

  // Listen to connectivity_plus network changes
  final connSub = Connectivity().onConnectivityChanged.listen((_) async {
    final hasConnection = await InternetConnectionChecker().hasConnection;
    controller.add(hasConnection);
  });

  // Emit initial state
  () async {
    final hasConnection = await InternetConnectionChecker().hasConnection;
    controller.add(hasConnection);
  }();

  ref.onDispose(() async {
   await connSub.cancel();
   await controller.close();
  });

  return controller.stream;
});
