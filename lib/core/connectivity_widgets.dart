import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity/connectivity_service.dart';
import 'widgets/offline_dialog.dart';

class ConnectivityListener extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectivityListener({super.key, required this.child});

  @override
  ConsumerState<ConnectivityListener> createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends ConsumerState<ConnectivityListener> {
  bool _wasOnline = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen must be called during build for Consumer widgets
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (prev, next) {
      final online = next.asData?.value ?? true;
      if (!online && _wasOnline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineDialog().showBanner(context: context);
        });
      } else if (online && !_wasOnline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineDialog().hideBanner(context: context);
        });
      }
      _wasOnline = online;
    });

    return widget.child;
  }
}
