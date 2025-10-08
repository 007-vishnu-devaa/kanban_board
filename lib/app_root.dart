import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/connectivity/connectivity_service.dart';

class AppRoot extends ConsumerWidget {
  final Widget child;
  const AppRoot({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);

    return connectivity.when(
      data: (online) {
        return Stack(
          children: [
            child,
            if (!online)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Material(
                  color: Colors.red,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: const Text(
                        'No internet connection',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
