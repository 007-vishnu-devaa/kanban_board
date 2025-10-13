import 'package:flutter/material.dart';

class ConfirmationDialog {
  void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String okayBtnText,
    required VoidCallback onOkayBtnPressed,
    String? cancelBtnText,
    required bool isCancelBtnVisible,
    required String contentMsg
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Text(contentMsg),
          ),
          actions: [
            TextButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.teal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(cancelBtnText ?? 'No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 22),
              ),
              onPressed: onOkayBtnPressed,
              child: Text(okayBtnText.isEmpty ? 'Yes' : okayBtnText),
            ),
          ],
        );
      },
    );
  }
}
