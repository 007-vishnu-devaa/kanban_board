import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:kanbanboard/core/app_strings.dart';

class OfflineDialog {
  const OfflineDialog();

  Future<void> showBanner({required BuildContext context, String title = 'No internet connection', String message = AppStrings.offlineText}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message),
        actions: [
          TextButton(
             style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 14), 
                    ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          SizedBox(width: 2),
          ElevatedButton(
             style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, 
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                        ),
            onPressed: () {
              // Open system Wi-Fi settings
              AppSettings.openWIFISettings();
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void hideBanner({required BuildContext context}){
  }
}
